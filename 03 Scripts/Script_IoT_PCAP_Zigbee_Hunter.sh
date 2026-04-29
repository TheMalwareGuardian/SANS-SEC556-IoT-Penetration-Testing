#!/bin/bash

# ============================================================
#  IoT_PCAP_Zigbee_Hunter.sh - Zigbee Traffic Recon & Key Hunting
#  TheMalwareGuardian | github.com/TheMalwareGuardian
# ============================================================

PCAP="$1"



# Colors

BOLD=$'\033[1m'
RESET=$'\033[0m'
C_CYAN=$'\033[1;36m'
C_YELLOW=$'\033[1;33m'
C_GREEN=$'\033[1;32m'
C_RED=$'\033[1;31m'
C_WHITE=$'\033[1;37m'
C_DARK=$'\033[2;37m'



# Helpers

section() {
	echo ""
	echo -e "${C_CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
	printf "${C_CYAN}${BOLD}║${RESET}  ${C_WHITE}${BOLD}%-52s${RESET}${C_CYAN}${BOLD}║${RESET}\n" "$1"
	echo -e "${C_CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
	echo ""
}

count_filter() {
	tshark -r "$PCAP" -Y "$1" 2>/dev/null | wc -l | tr -d ' '
}

truncate() {
	echo "$1" | cut -c1-"$2"
}

print_empty() {
	echo -e "  ${C_DARK}No entries identified.${RESET}"
}



# Checks

if [ -z "$PCAP" ]; then
	echo -e "${C_RED}Usage:${RESET} $0 <zigbee.pcap>"
	exit 1
fi

if [ ! -f "$PCAP" ]; then
	echo -e "${C_RED}[ERROR] File not found:${RESET} $PCAP"
	exit 1
fi

if ! command -v tshark &>/dev/null; then
	echo -e "${C_RED}[ERROR] tshark required${RESET}"
	exit 1
fi

FILE_INFO=$(file "$PCAP")

if echo "$FILE_INFO" | grep -qi "ASCII"; then
	IS_DCF=1
else
	IS_DCF=0
fi



# Banner

echo ""
echo -e "${C_CYAN}${BOLD}IoT Zigbee Hunter${RESET}"
echo -e "Target: ${C_YELLOW}${BOLD}$PCAP${RESET}"
echo ""

# 1. CAPTURE SUMMARY
section "1. CAPTURE SUMMARY"

if command -v capinfos &>/dev/null; then
	capinfos "$PCAP" 2>/dev/null | \
	grep -E "Number of packets|Capture duration" | sed 's/^/  /'
fi



# 2. TRAFFIC COUNTERS

section "2. TRAFFIC COUNTERS"

WPAN=$(count_filter "wpan")
NWK=$(count_filter "zbee_nwk")
APS=$(count_filter "zbee_aps")

echo "  WPAN frames : $WPAN"
echo "  NWK frames  : $NWK"
echo "  APS frames  : $APS"



# 3. SECURITY ANALYSIS

section "3. LAYERED SECURITY"

MAC_SEC=$(count_filter "wpan.security == 1")
NWK_SEC=$(count_filter "zbee_nwk.sec == 1")
APS_SEC=$(count_filter "zbee_aps.security == 1")

echo "  MAC Security : $MAC_SEC"
echo "  NWK Security : $NWK_SEC"
echo "  APS Security : $APS_SEC"

[ "$MAC_SEC" -gt 0 ] && echo -e "  ${C_RED}→ MAC encryption detected${RESET}"
[ "$NWK_SEC" -gt 0 ] && echo -e "  ${C_YELLOW}→ NWK encryption detected${RESET}"
[ "$APS_SEC" -gt 0 ] && echo -e "  ${C_YELLOW}→ APS encryption detected${RESET}"

if [ "$MAC_SEC" -eq 0 ] && [ "$NWK_SEC" -eq 0 ] && [ "$APS_SEC" -eq 0 ]; then
	echo -e "  ${C_GREEN}→ No security detected${RESET}"
fi



# 4. TRANSPORT KEY EVENTS

section "4. TRANSPORT KEY EVENTS"

KEY_EVENTS=$(tshark -r "$PCAP" \
	-Y "zbee_aps.cmd.id == 0x05" \
	2>/dev/null | head -n 20)

if [ -z "$KEY_EVENTS" ]; then
	print_empty
else
	echo "$KEY_EVENTS" | sed 's/^/  /'
fi



# 5. OTA KEY SNIFFING

section "5. OTA KEY SNIFFING (KILLERBEE)"

if [ "$IS_DCF" -eq 1 ]; then
	echo -e "  ${C_DARK}Skipping zbdsniff (DCF not supported)${RESET}"
else
	if command -v zbdsniff &>/dev/null; then
		ZBD=$(zbdsniff -f "$PCAP" 2>/dev/null)

		if echo "$ZBD" | grep -qi "Network Key"; then
			echo "$ZBD" | sed 's/^/  /'
		else
			echo -e "  ${C_DARK}No OTA key recovered${RESET}"
		fi
	else
		echo -e "  ${C_DARK}zbdsniff not installed${RESET}"
	fi
fi



# 6. JOIN / REJOIN / ASSOCIATION EVENTS

section "6. JOIN / REJOIN / ASSOCIATION EVENTS"

JOIN_FILTER="\
	(wpan.cmd == 0x01 || wpan.cmd == 0x02) || \
	(zbee_nwk.cmd.id == 0x06 || zbee_nwk.cmd.id == 0x07) || \
	(zbee_aps.cmd.id == 0x05)"

JOIN_EVENTS=$(tshark -r "$PCAP" \
	-Y "$JOIN_FILTER" \
	-T fields \
	-e frame.number \
	-e frame.time_relative \
	-e _ws.col.Source \
	-e _ws.col.Destination \
	-e _ws.col.Info \
	2>/dev/null | uniq | head -n 25)

if [ -z "$JOIN_EVENTS" ]; then
	echo -e "  ${C_YELLOW}[!] No join/rejoin activity detected${RESET}"
else
	printf "  ${C_WHITE}${BOLD}%-6s %-12s %-24s %-24s %-30s${RESET}\n" "Frame" "Time" "Source" "Destination" "Event"
	echo -e "${C_DARK}  ----------------------------------------------------------------------------------------------${RESET}"

	echo "$JOIN_EVENTS" | while IFS=$'\t' read -r f t s d i; do
		F=$(truncate "$f" 6)
		T=$(truncate "$t" 12)
		S=$(truncate "$s" 24)
		D=$(truncate "$d" 24)
		I=$(truncate "$i" 30)

		printf "  ${C_GREEN}%-6s${RESET} ${C_YELLOW}%-12s${RESET} %-24s %-24s %-30s\n" "$F" "$T" "$S" "$D" "$I"
	done
fi



# DONE

echo ""
echo -e "${C_GREEN}${BOLD}Zigbee Hunter Complete.${RESET}"
echo ""
