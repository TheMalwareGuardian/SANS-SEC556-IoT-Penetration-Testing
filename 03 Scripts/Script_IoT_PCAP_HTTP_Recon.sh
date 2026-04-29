#!/bin/bash

# ============================================================
#  IoT_PCAP_HTTP_Recon.sh - IoT API & HTTP Forensics
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



# Input validation

if [ -z "$PCAP" ]; then
	echo -e "${C_RED}${BOLD}Usage:${RESET}  $0 <pcap_file>"
	exit 1
fi

if [ ! -f "$PCAP" ]; then
	echo -e "${C_RED}[ERROR]${RESET} File not found: ${BOLD}$PCAP${RESET}"
	exit 1
fi

if ! command -v tshark &>/dev/null; then
	echo -e "${C_RED}[ERROR]${RESET} tshark is required"
	exit 1
fi



# Banner

echo ""
echo -e "${C_CYAN}${BOLD}"
echo "  ██╗  ██╗████████╗████████╗██████╗ "
echo "  ██║  ██║╚══██╔══╝╚══██╔══╝██╔══██╗"
echo "  ███████║   ██║      ██║   ██████╔╝"
echo "  ██╔══██║   ██║      ██║   ██╔═══╝ "
echo "  ██║  ██║   ██║      ██║   ██║     "
echo "  ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚═╝     "
echo -e "${RESET}"
echo -e "  ${C_DARK}IoT API & HTTP Recon  •  TheMalwareGuardian${RESET}"
echo ""
echo -e "  ${C_WHITE}${BOLD}Target :${RESET}  ${C_YELLOW}${BOLD}$PCAP${RESET}"
echo ""



# 1. HTTP FLOWS

section "1. HTTP COMMUNICATION FLOWS"

tshark -r "$PCAP" -Y "http.request" -T fields -e ip.src -e ip.dst -e http.host 2>/dev/null | awk 'NF>=3 {print $1 "|" $2 "|" $3}' | sort -u | head -n 15 | while IFS='|' read -r src dst host; do
	printf "  ${C_CYAN}%-18s -> %-18s  %s${RESET}\n" "$src" "$dst" "$host"
done



# 2. DISCOVERED API ENDPOINTS

section "2. DISCOVERED API ENDPOINTS"

tshark -r "$PCAP" -Y "http.request" -T fields -e http.request.method -e http.host -e http.request.uri 2>/dev/null | awk '{print $1 " http://" $2 $3}' | sort -u | head -n 20 | while read -r line; do
	echo -e "  ${C_YELLOW}$line${RESET}"
done



# 3. LOGIN CREDENTIALS

section "3. CREDENTIAL HARVESTING (PLAINTEXT)"

CREDS=$(tshark -r "$PCAP" -Y 'http.request.method == "POST"' -T fields -e ip.src -e http.host -e http.file_data 2>/dev/null | grep -Ei "email|user|pass|login")

if [ -z "$CREDS" ]; then
	echo -e "  ${C_DARK}No credentials found${RESET}"
else
	echo "$CREDS" | while IFS=$'\t' read -r ip host data; do
		echo -e "  ${C_RED}$ip -> $host${RESET}"
		echo -e "    ${C_WHITE}$data${RESET}"
		echo ""
	done
fi



# 4. SESSION COOKIES

section "4. SESSION IDENTIFICATION (COOKIES)"

tshark -r "$PCAP" -Y "http.cookie" -T fields -e ip.src -e http.host -e http.cookie 2>/dev/null | head -n 10 | while IFS=$'\t' read -r ip host cookie; do
	echo -e "  ${C_BLUE}$ip -> $host${RESET}"
	echo -e "    ${C_WHITE}$cookie${RESET}"
	echo ""
done



# 5. AUTHENTICATION TOKENS

section "5. AUTH HEADERS (TOKENS / BASIC AUTH)"

tshark -r "$PCAP" -Y "http.authorization" -T fields -e ip.src -e http.host -e http.authorization 2>/dev/null | while IFS=$'\t' read -r ip host auth; do
	echo -e "  ${C_MAGENTA}$ip -> $host${RESET}"
	echo -e "    ${C_WHITE}$auth${RESET}"
	echo ""
done



# 6. API ATTACK CHAIN

section "6. API ATTACK CHAIN RECONSTRUCTION"

echo -e "  ${C_GREEN}${BOLD}Login phase:${RESET}"

tshark -r "$PCAP" -Y 'http.request.method == "POST" && http.request.uri contains "login"' -T fields -e ip.src -e http.host -e http.file_data 2>/dev/null | while IFS=$'\t' read -r ip host data; do
	echo -e "  ${C_GREEN}$ip -> $host${RESET}"
	echo -e "    ${C_WHITE}$data${RESET}"
done

echo ""
echo -e "  ${C_GREEN}${BOLD}API usage after login:${RESET}"

tshark -r "$PCAP" -Y 'http.request.method == "GET" || http.request.method == "POST"' -T fields -e ip.src -e http.request.method -e http.host -e http.request.uri 2>/dev/null | head -n 20 | while read -r ip method host uri; do
	echo -e "  ${C_GREEN}$ip -> $method http://$host$uri${RESET}"
done



# DONE

echo ""
echo -e "${C_CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
printf "${C_CYAN}${BOLD}║${RESET}  ${C_GREEN}${BOLD}%-52s${RESET}${C_CYAN}${BOLD}║${RESET}\n" "HTTP Recon complete."
echo -e "${C_CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
