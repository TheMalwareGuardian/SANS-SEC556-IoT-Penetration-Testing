#!/bin/bash

# ============================================================
#  IoT_PCAP_MQTT_Recon.sh - IoT Network Forensics
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
C_BLUE=$'\033[1;34m'
C_MAGENTA=$'\033[1;35m'
C_WHITE=$'\033[1;37m'
C_GRAY=$'\033[0;37m'
C_DARK=$'\033[2;37m'



# Helpers

section() {
	echo ""
	echo -e "${C_CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
	printf "${C_CYAN}${BOLD}║${RESET}  ${C_WHITE}${BOLD}%-52s${RESET}${C_CYAN}${BOLD}║${RESET}\n" "$1"
	echo -e "${C_CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
	echo ""
}

subsection() {
	local color="${2:-$C_YELLOW}"
	echo -e "\n  ${color}${BOLD}▸ $1${RESET}"
}

divider() {
	echo -e "${C_DARK}  ────────────────────────────────────────────────────────────${RESET}"
}

dividermini() {
	echo -e "${C_DARK}  ─────────────────────────────────────────────${RESET}"
}

kv() {
	printf "    ${1}◆${RESET}  ${C_WHITE}%-22s${RESET}  ${1}${BOLD}%s${RESET}\n" "$2" "$3"
}

box_node() {
	local color="$1" title="$2"
	shift 2
	local w=46 cw=44
	local hbar
	hbar=$(printf '─%.0s' $(seq 1 $w))
	echo -e "  ${color}${BOLD}╭${hbar}╮${RESET}"
	printf "  ${color}${BOLD}│${RESET}  ${color}${BOLD}%-${cw}s${RESET}${color}${BOLD}│${RESET}\n" "$title"
	echo -e "  ${color}${BOLD}├${hbar}┤${RESET}"
	for line in "$@"; do
		printf "  ${color}${BOLD}│${RESET}  ${C_WHITE}%-${cw}s${RESET}${color}${BOLD}│${RESET}\n" "$line"
	done
	echo -e "  ${color}${BOLD}╰${hbar}╯${RESET}"
}

connector() {
	echo -e "  ${C_DARK}             │"
	echo -e "  ${C_DARK}             │  $1"
	echo -e "  ${C_DARK}             ▼${RESET}"
}

flow_table() {
	local color="$1" proto="$2" data="$3"
	printf "    ${C_WHITE}${BOLD}%-18s  ->  %-18s  %s${RESET}\n" "Source" "Destination" "Protocol"
	echo -e "${C_DARK}    ─────────────────────────────────────────────────────${RESET}"
	echo "$data" | awk -F'|' -v p="$proto" '{printf "    %-18s  ->  %-18s  %s\n", $1, $2, p}' \
	| while IFS= read -r line; do echo -e "${color}$line${RESET}"; done
}

check_dep() {
	if ! command -v "$1" &>/dev/null; then
		echo -e "${C_RED}[ERROR]${RESET} Required: ${BOLD}$1${RESET}"; exit 1
	fi
}



# Input validation

if [ -z "$PCAP" ]; then
	echo -e "${C_RED}${BOLD}Usage:${RESET}  $0 <pcap_file>"; exit 1
fi
if [ ! -f "$PCAP" ]; then
	echo -e "${C_RED}[ERROR]${RESET} File not found: ${BOLD}$PCAP${RESET}"; exit 1
fi
check_dep tshark
check_dep awk



# Banner

echo ""
echo -e "${C_CYAN}${BOLD}"
echo "  ███╗   ███╗ ██████╗  ████████╗████████╗"
echo "  ████╗ ████║██╔═══██╗╚══██╔══╝╚══██╔══╝"
echo "  ██╔████╔██║██║   ██║   ██║      ██║   "
echo "  ██║╚██╔╝██║██║▄▄ ██║   ██║      ██║   "
echo "  ██║ ╚═╝ ██║╚██████╔╝   ██║      ██║   "
echo "  ╚═╝     ╚═╝ ╚══▀▀═╝    ╚═╝      ╚═╝   "
echo -e "${RESET}"
echo -e "  ${C_DARK}IoT Network Forensics  •  TheMalwareGuardian${RESET}"
echo ""
echo -e "  ${C_WHITE}${BOLD}Target :${RESET}  ${C_YELLOW}${BOLD}$PCAP${RESET}"
echo -e "  ${C_WHITE}${BOLD}Date   :${RESET}  ${C_GRAY}$(date '+%Y-%m-%d  %H:%M:%S')${RESET}"
echo ""


# 1. DEVICE MAPPING

section "1. DEVICE MAPPING"

tshark -r "$PCAP" -T fields -E separator='|' -e eth.src -e ip.src -e eth.src.oui_resolved 2>/dev/null | awk -F'|' '
NF >= 1 && $1 != "" {
	mac    = $1
	ip     = ($2 != "") ? $2 : "-"
	vendor = ($3 != "") ? $3 : "Unknown"
	printf "%-20s  %-16s  %s\n", mac, ip, vendor
}' | sort -u > /tmp/pcap_devices.txt

printf "  ${C_WHITE}${BOLD}  %-20s  %-16s  %s${RESET}\n" "MAC Address" "IP Address" "Vendor"
divider

while IFS= read -r line; do
	mac=$(echo "$line"    | awk '{print $1}')
	ip=$(echo "$line"     | awk '{print $2}')
	vendor=$(echo "$line" | awk '{for(i=3;i<=NF;i++) printf $i (i<NF?" ":""); print ""}')
	if echo "$line" | grep -q "Unknown"; then
		printf "  ${C_BLUE}  %-20s${RESET}  ${C_GRAY}%-16s  %s${RESET}\n" "$mac" "$ip" "$vendor"
	else
		printf "  ${C_GREEN}  %-20s${RESET}  ${C_WHITE}%-16s${RESET}  ${C_DARK}%s${RESET}\n" "$mac" "$ip" "$vendor"
	fi
done < /tmp/pcap_devices.txt


# 2. NETWORK STATISTICS

section "2. NETWORK STATISTICS"

TOTAL_ENDPOINTS_IP=$(awk '$2 != "-" {print $2}' /tmp/pcap_devices.txt | sort -u | wc -l | tr -d ' ')
TOTAL_DEVICES_MAC=$(awk '{print $1}' /tmp/pcap_devices.txt | sort -u | wc -l | tr -d ' ')
TOTAL_PACKETS=$(tshark -r "$PCAP" 2>/dev/null | wc -l | tr -d ' ')

kv "$C_CYAN"    "Total Packets"    "$TOTAL_PACKETS"
kv "$C_GREEN"   "IP Endpoints"     "$TOTAL_ENDPOINTS_IP"
kv "$C_BLUE"    "MAC Devices"      "$TOTAL_DEVICES_MAC"



# 3. NODE CLASSIFICATION

section "3. NODE CLASSIFICATION"

# Sensor detection
SENSOR_VENDOR=$(awk '
$2 != "-" {
	vendor = ""
	for (i = 3; i <= NF; i++) vendor = vendor $i " "
	gsub(/^ +| +$/, "", vendor)
	print vendor
}' /tmp/pcap_devices.txt | sort | uniq -c | sort -nr | head -n1 | sed 's/^[[:space:]]*[0-9]* //')

SENSORS=0
if [ -n "$SENSOR_VENDOR" ]; then
	SENSORS=$(awk -v v="$SENSOR_VENDOR" '
		$2 != "-" && index($0, v) > 0 { macs[$1] = 1 }
		END { print length(macs) }
	' /tmp/pcap_devices.txt)
fi

# Infrastructure
INFRA_MAC=$(awk '
{
	mac = $1; ip = $2
	if (ip != "-") { count[mac]++; ips[mac] = ips[mac] ip " " }
}
END { for (m in count) if (count[m] > 1) print m "|" ips[m] }
' /tmp/pcap_devices.txt)

INFRA_COUNT=0
[ -n "$INFRA_MAC" ] && INFRA_COUNT=$(echo "$INFRA_MAC" | grep -c '|')

# Services
BROKER=$(tshark -r "$PCAP" -T fields -e ip.dst -e tcp.dstport 2>/dev/null | awk '$2 == 1883 { count[$1]++ } END { for (i in count) print count[i], i }' | sort -nr | head -n1 | awk '{print $2}')
[ -z "$BROKER" ] && BROKER="Not detected"

VIDEO=$(tshark -r "$PCAP" -T fields -e ip.dst -e udp.length 2>/dev/null | awk '$2 > 500 { count[$1]++ } END { for (i in count) print count[i], i }' | sort -nr | head -n1 | awk '{print $2}')
[ -z "$VIDEO" ] && VIDEO="Not detected"

DNS_SERVERS=$(tshark -r "$PCAP" -Y "dns.flags.response == 1" -T fields -e ip.src 2>/dev/null | awk 'NF { count[$1]++ } END { for (i in count) print count[i], i }' | sort -nr)

DNS_PAIRS=$(tshark -r "$PCAP" -Y "dns.flags.response == 1" -T fields -e ip.dst -e ip.src 2>/dev/null | awk 'NF == 2 { pairs[$1 "|" $2]++ } END { for (p in pairs) print p }' | sort -u)

# Display
subsection "Sensors" "$C_GREEN"
kv "$C_GREEN" "Vendor"  "${SENSOR_VENDOR:-Unknown}"
kv "$C_GREEN" "Count"   "$SENSORS devices"

subsection "Infrastructure  (multi-IP MACs)" "$C_BLUE"
kv "$C_BLUE" "Nodes" "$INFRA_COUNT"
if [ -n "$INFRA_MAC" ]; then
	echo ""
	echo "$INFRA_MAC" | while IFS='|' read -r mac ips; do
		printf "    ${C_BLUE}${BOLD}%-22s${RESET}  ${C_GRAY}%s${RESET}\n" "$mac" "$ips"
	done
fi

subsection "Services" "$C_YELLOW"
kv "$C_YELLOW"  "MQTT Broker"   "$BROKER"
kv "$C_MAGENTA" "Video Server"  "$VIDEO"
echo ""

if [ -n "$DNS_SERVERS" ]; then
	printf "    ${C_CYAN}${BOLD}%-26s  %s${RESET}\n" "DNS Server" "Responses"
	dividermini
	echo "$DNS_SERVERS" | while read -r count ip; do
		printf "    ${C_CYAN}${BOLD}%-26s${RESET}  ${C_GRAY}%s${RESET}\n" "$ip" "$count responses"
	done
else
	kv "$C_CYAN" "DNS Server" "Not detected"
fi

if [ -n "$DNS_PAIRS" ]; then
	echo ""
	printf "    ${C_GRAY}%-18s       %s${RESET}\n" "Client" "DNS Server"
	dividermini
	echo "$DNS_PAIRS" | awk -F'|' '{printf "    %-18s  ->  %s\n", $1, $2}' | while IFS= read -r line; do echo -e "  ${C_DARK}  $line${RESET}"; done
fi



# 4. HIGH-ACTIVITY NODES

section "4. HIGH-ACTIVITY NODES  (top 10)"

printf "  ${C_WHITE}${BOLD}  %-18s  %-10s  %-22s  %s${RESET}\n" "IP Address" "Packets" "Activity" "%"
divider

tshark -r "$PCAP" -T fields -e ip.src -e ip.dst 2>/dev/null \
| tr '\t' '\n' | grep -v '^$' | sort | uniq -c | sort -nr | head -n 10 \
| awk 'BEGIN { max = 0 }
NR == 1 { max = $1 }
{
	n = int(($1 / max) * 20); if (n < 1) n = 1
	bar = ""; for (i = 0; i < n; i++) bar = bar "█"
	printf "%s|%d|%-20s|%d\n", $2, $1, bar, int(($1/max)*100)
}' | while IFS='|' read -r ip count bar pct; do
	if [ "$ip" = "$BROKER" ] || [ "$ip" = "$VIDEO" ]; then
		printf "  ${C_YELLOW}  %-18s  %-10s  %-22s  %s%%${RESET}\n" "$ip" "$count" "$bar" "$pct"
	else
		printf "  ${C_GREEN}  %-18s  %-10s  %-22s  %s%%${RESET}\n" "$ip" "$count" "$bar" "$pct"
	fi
done



# 5. NETWORK ARCHITECTURE MAP

section "5. NETWORK ARCHITECTURE MAP"

box_node "$C_GREEN" "SENSORS  [ $SENSORS devices ]" \
	"Vendor : ${SENSOR_VENDOR:-Unknown}" \
	"Proto  : MQTT / DNS / UDP"

connector "MQTT  :1883"

box_node "$C_YELLOW" "MQTT BROKER" \
	"Address : $BROKER"

connector "Internal routing"

if [ -n "$INFRA_MAC" ]; then
	gw_mac=$(echo "$INFRA_MAC" | awk -F'|' '{print $1}' | head -n1)
	gw_ips=$(echo "$INFRA_MAC" | awk -F'|' '{print $2}' | head -n1)
	box_node "$C_BLUE" "GATEWAY / ROUTER" \
		"MAC : $gw_mac" \
		"IPs : $gw_ips"
else
	box_node "$C_BLUE" "GATEWAY / ROUTER" "Not detected"
fi

connector "UDP stream"

box_node "$C_MAGENTA" "VIDEO SERVER" \
	"Address : $VIDEO"

if [ -n "$DNS_SERVERS" ]; then
	echo ""
	echo -e "  ${C_DARK}  ┄┄ DNS layer ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄${RESET}"
	echo "$DNS_SERVERS" | while read -r count ip; do
		box_node "$C_CYAN" "DNS SERVER" \
			"Address   : $ip" \
			"Responses : $count"
	done
fi

echo ""



# 6. SAMPLE FLOWS

section "6. SAMPLE FLOWS"

subsection "MQTT flows  (port 1883)" "$C_YELLOW"
echo ""
MQTT_FLOWS=$(tshark -r "$PCAP" -T fields -e ip.src -e ip.dst -e tcp.dstport 2>/dev/null | awk '$3 == 1883 { print $1 "|" $2 }' | sort -u | head -n 8)
if [ -n "$MQTT_FLOWS" ]; then
	flow_table "$C_YELLOW" "MQTT" "$MQTT_FLOWS"
else
	echo -e "  ${C_DARK}  No MQTT flows captured.${RESET}"
fi

subsection "Video / Streaming flows" "$C_MAGENTA"
echo ""
VIDEO_FLOWS=""
if [ "$VIDEO" != "Not detected" ]; then
	VIDEO_FLOWS=$(tshark -r "$PCAP" -T fields -e ip.src -e ip.dst 2>/dev/null | awk -v v="$VIDEO" '$2 == v { print $1 "|" $2 }' | sort -u | head -n 8)
fi
if [ -n "$VIDEO_FLOWS" ]; then
	flow_table "$C_MAGENTA" "VIDEO" "$VIDEO_FLOWS"
else
	echo -e "  ${C_DARK}  No video flows captured.${RESET}"
fi

subsection "DNS flows" "$C_CYAN"
echo ""
DNS_FLOWS=$(tshark -r "$PCAP" -Y "dns.flags.response == 1" -T fields -e ip.src -e ip.dst 2>/dev/null | awk '{ print $1 "|" $2 }' | sort -u | head -n 8)
if [ -n "$DNS_FLOWS" ]; then
	flow_table "$C_CYAN" "DNS" "$DNS_FLOWS"
else
	echo -e "  ${C_DARK}  No DNS flows captured.${RESET}"
fi



# 7. MQTT CREDENTIALS
section "7. MQTT CREDENTIALS  (CONNECT packets)"

RAW_CREDS=$(tshark -r "$PCAP" -d tcp.port==1883,mqtt -o tcp.desegment_tcp_streams:TRUE -Y "mqtt.msgtype == 1 && mqtt.username && mqtt.passwd" -T fields -e mqtt.username -e mqtt.passwd 2>/dev/null)

if [ -z "$RAW_CREDS" ]; then
	echo -e "  ${C_DARK}  No MQTT credentials found in capture.${RESET}"
else

	# Top credentials by frequency
	subsection "Top credentials  (by frequency)" "$C_RED"
	echo ""
	printf "    ${C_WHITE}${BOLD}%-20s  %-20s  %s${RESET}\n" "Username" "Password" "Count"
	divider
	echo "$RAW_CREDS" | sort | uniq -c | sort -nr | head -n 10 | awk '{
		count = $1
		user  = $2
		pass  = $3
		printf "    %-20s  %-20s  %d\n", user, pass, count
	}' | while IFS= read -r line; do
		echo -e "  ${C_RED}$line${RESET}"
	done

	# Credentials per sensor
	echo ""
	subsection "Credentials per sensor  (IP -> user : pass)" "$C_YELLOW"
	echo ""
	printf "    ${C_WHITE}${BOLD}%-18s  %-20s  %s${RESET}\n" "Source IP" "Username" "Password"
	divider
	tshark -r "$PCAP" -d tcp.port==1883,mqtt -o tcp.desegment_tcp_streams:TRUE -Y "mqtt.msgtype == 1 && mqtt.username && mqtt.passwd" -T fields -e ip.src -e mqtt.username -e mqtt.passwd 2>/dev/null | sort -u | head -n 20 | awk '{printf "    %-18s  %-20s  %s\n", $1, $2, $3}' | while IFS= read -r line; do
		echo -e "  ${C_YELLOW}$line${RESET}"
	done

fi



# DONE

echo ""
echo -e "${C_CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
printf "${C_CYAN}${BOLD}║${RESET}  ${C_GREEN}${BOLD}%-52s${RESET}${C_CYAN}${BOLD}║${RESET}\n" "Analysis complete."
echo -e "${C_CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

rm -f /tmp/pcap_devices.txt
