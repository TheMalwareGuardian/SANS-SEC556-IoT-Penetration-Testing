#!/bin/bash

# ============================================================
#  IoT_Firmware_AutoPwn_Analyzer.sh - Firmware Analysis, Extraction & Secret Hunting
#  TheMalwareGuardian | github.com/TheMalwareGuardian
# ============================================================

TARGET="$1"



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
	echo -e "${C_MAGENTA}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
	printf "${C_MAGENTA}${BOLD}║${RESET}  ${C_WHITE}${BOLD}%-52s${RESET}${C_MAGENTA}${BOLD}║${RESET}\n" "$1"
	echo -e "${C_MAGENTA}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
	echo ""
}

print_empty() {
	echo -e "  ${C_DARK}No entries identified.${RESET}"
}

safe_head() {
	head -n "${1:-20}" 2>/dev/null
}



# Banner

echo ""
echo -e "${C_MAGENTA}${BOLD}"
echo "   ███████╗██╗██████╗ ███╗   ███╗██╗    ██╗ █████╗ ██████╗ ███████╗"
echo "   ██╔════╝██║██╔══██╗████╗ ████║██║    ██║██╔══██╗██╔══██╗██╔════╝"
echo "   █████╗  ██║██████╔╝██╔████╔██║██║ █╗ ██║███████║██████╔╝█████╗  "
echo "   ██╔══╝  ██║██╔══██╗██║╚██╔╝██║██║███╗██║██╔══██║██╔══██╗██╔══╝  "
echo "   ██║     ██║██║  ██║██║ ╚═╝ ██║╚███╔███╔╝██║  ██║██║  ██║███████╗"
echo "   ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝"
echo -e "${RESET}"
echo -e "  ${C_DARK}Firmware AutoPwn Analyzer • TheMalwareGuardian${RESET}"
echo ""
echo -e "  ${C_WHITE}${BOLD}Target:${RESET} ${C_YELLOW}${BOLD}$TARGET${RESET}"
echo ""



# Checks

if [ -z "$TARGET" ]; then
	echo -e "${C_RED}Usage:${RESET} $0 <firmware.bin>"
	exit 1
fi

if [ ! -f "$TARGET" ]; then
	echo -e "${C_RED}[ERROR] File not found:${RESET} $TARGET"
	exit 1
fi

if ! command -v binwalk &>/dev/null; then
	echo -e "${C_RED}[ERROR] binwalk is required${RESET}"
	exit 1
fi



# 1. FILE IDENTIFICATION

section "1. FILE IDENTIFICATION"

file "$TARGET" | sed 's/^/  /'



# 2. ENTROPY ANALYSIS

section "2. ENTROPY ANALYSIS (ENT)"

if command -v ent &>/dev/null; then
	ent "$TARGET" | tail -n 5 | sed 's/^/  /'
else
	echo -e "  ${C_DARK}ent not installed.${RESET}"
fi



# 3. BINWALK ENTROPY

section "3. BINWALK ENTROPY"

binwalk -E "$TARGET" 2>/dev/null | sed 's/^/  /'



# 4. BINWALK SIGNATURE SCAN

section "4. FIRMWARE STRUCTURE (BINWALK)"

binwalk "$TARGET" 2>/dev/null | sed 's/^/  /'



# 5. EXTRACTION

section "5. FILESYSTEM EXTRACTION"

binwalk -e -M "$TARGET" >/dev/null 2>&1

EXTRACT_DIR=$(find . -maxdepth 2 -type d -name "_$(basename "$TARGET").extracted" | head -n 1)

if [ -z "$EXTRACT_DIR" ]; then
	EXTRACT_DIR=$(find . -type d -name "*$(basename "$TARGET").extracted" | head -n 1)
fi

if [ -z "$EXTRACT_DIR" ]; then
	echo -e "  ${C_RED}Extraction failed or no filesystem was extracted.${RESET}"
	exit 1
fi

echo -e "  ${C_GREEN}Extracted to:${RESET} $EXTRACT_DIR"



# 6. FILESYSTEM OVERVIEW

section "6. FILESYSTEM OVERVIEW"

find "$EXTRACT_DIR" -maxdepth 2 -type d 2>/dev/null | head -n 30 | sed 's/^/  /'



# 7. SECRET HUNTING

section "7. SECRET HUNTING"

echo -e "  ${C_YELLOW}Searching for credential-like strings...${RESET}"
echo ""

RESULTS=$(grep -RniE "password|passwd|pwd|admin|root|token|secret|apikey|api_key|auth|credential|login" "$EXTRACT_DIR" 2>/dev/null | grep -viE "cacert|certificate authority|root ca|BEGIN CERTIFICATE" | head -n 30)

if [ -z "$RESULTS" ]; then
	print_empty
else
	echo "$RESULTS" | sed 's/^/  /'
fi



# 8. HIGH VALUE FILES

section "8. HIGH VALUE FILES"

RESULTS=$(find "$EXTRACT_DIR" -type f \( \
	-name "passwd" -o \
	-name "shadow" -o \
	-name "group" -o \
	-name "inittab" -o \
	-name "rcS" -o \
	-name "authorized_keys" -o \
	-name "known_hosts" -o \
	-name "id_rsa" -o \
	-name "id_dsa" -o \
	-name "*.pem" -o \
	-name "*.key" -o \
	-name "*.crt" \
\) 2>/dev/null | head -n 40)

if [ -z "$RESULTS" ]; then
	print_empty
else
	echo "$RESULTS" | sed 's/^/  /'
fi



# 9. PASSWORD DATABASES

section "9. PASSWORD DATABASES"

PASSWD_FILES=$(find "$EXTRACT_DIR" -type f -name "passwd" 2>/dev/null)
SHADOW_FILES=$(find "$EXTRACT_DIR" -type f -name "shadow" 2>/dev/null)

if [ -z "$PASSWD_FILES" ] && [ -z "$SHADOW_FILES" ]; then
	print_empty
else
	for f in $PASSWD_FILES; do
		echo -e "  ${C_GREEN}[+] passwd:${RESET} $f"
		cat "$f" 2>/dev/null | head -n 15 | sed 's/^/    /'
		echo ""
	done

	for f in $SHADOW_FILES; do
		echo -e "  ${C_RED}[+] shadow:${RESET} $f"
		cat "$f" 2>/dev/null | head -n 15 | sed 's/^/    /'
		echo ""
	done
fi



# 10. HARDCODED CREDENTIALS

section "10. HARDCODED CREDENTIALS"

RESULTS=$(grep -RniE "password\s*=|passwd\s*=|pwd\s*=|user(name)?\s*=|login\s*=|admin\s*=|root\s*=|psk\s*=|ssid\s*=|key\s*=" "$EXTRACT_DIR" 2>/dev/null | head -n 40)

if [ -z "$RESULTS" ]; then
	print_empty
else
	echo "$RESULTS" | sed 's/^/  /'
fi



# 11. NETWORK / WIFI CONFIGS

section "11. NETWORK CONFIGS (WIFI / WPA)"

RESULTS=$(grep -RniE "ssid|psk|wpa|wep|wireless|interface|gateway|dns|dhcp|static ip" "$EXTRACT_DIR" 2>/dev/null | head -n 40)

if [ -z "$RESULTS" ]; then
	print_empty
else
	echo "$RESULTS" | sed 's/^/  /'
fi



# 12. CONFIG FILE DISCOVERY

section "12. CONFIG FILE DISCOVERY"

RESULTS=$(find "$EXTRACT_DIR" -type f \( \
	-name "*.conf" -o \
	-name "*.cfg" -o \
	-name "*.ini" -o \
	-name "*.xml" -o \
	-name "*.json" -o \
	-name "*.properties" \
\) 2>/dev/null | head -n 40)

if [ -z "$RESULTS" ]; then
	print_empty
else
	echo "$RESULTS" | sed 's/^/  /'
fi



# 13. PRIVATE KEYS & CERTIFICATES

section "13. PRIVATE KEYS & CERTIFICATES"

RESULTS=$(find "$EXTRACT_DIR" -type f \( \
	-name "*.pem" -o \
	-name "*.key" -o \
	-name "*.crt" -o \
	-name "*.cer" \
\) 2>/dev/null | head -n 40)

if [ -z "$RESULTS" ]; then
	print_empty
else
	echo "$RESULTS" | sed 's/^/  /'
fi

echo ""
echo -e "  ${C_YELLOW}Private key markers:${RESET}"

RESULTS=$(grep -RniE "BEGIN (RSA |DSA |EC |OPENSSH )?PRIVATE KEY" "$EXTRACT_DIR" 2>/dev/null | head -n 20)

if [ -z "$RESULTS" ]; then
	print_empty
else
	echo "$RESULTS" | sed 's/^/  /'
fi



# 14. SERVICES & INTERESTING BINARIES

section "14. SERVICES & INTERESTING BINARIES"

RESULTS=$(find "$EXTRACT_DIR" -type f 2>/dev/null | grep -Ei "/(busybox|telnetd|dropbear|sshd|ssh|httpd|boa|lighttpd|uhttpd|nginx|openssl|wget|curl|nc|netcat)$" | head -n 40)

if [ -z "$RESULTS" ]; then
	print_empty
else
	echo "$RESULTS" | sed 's/^/  /'
fi



# 15. WEB / API ENDPOINTS

section "15. WEB / API ENDPOINTS"

RESULTS=$(grep -RniE "cgi-bin|\.cgi|\.php|/api/|/login|/admin|Authorization|Basic " "$EXTRACT_DIR" 2>/dev/null | head -n 40)

if [ -z "$RESULTS" ]; then
	print_empty
else
	echo "$RESULTS" | sed 's/^/  /'
fi



# 16. INIT / STARTUP SCRIPTS

section "16. INIT / STARTUP SCRIPTS"

RESULTS=$(find "$EXTRACT_DIR" -type f \( \
	-path "*/etc/init.d/*" -o \
	-name "inittab" -o \
	-name "rcS" -o \
	-name "rc.local" \
\) 2>/dev/null | head -n 40)

if [ -z "$RESULTS" ]; then
	print_empty
else
	echo "$RESULTS" | sed 's/^/  /'
fi



# 17. STRINGS ANALYSIS

section "17. STRINGS (INTERESTING DATA)"

RESULTS=$(strings "$TARGET" 2>/dev/null | grep -Ei "http://|https://|ftp://|admin|login|password|passwd|token|secret|/cgi-bin/|\.php|\.cgi" | head -n 40)

if [ -z "$RESULTS" ]; then
	print_empty
else
	echo "$RESULTS" | sed 's/^/  /'
fi



# 18. QUICK ATTACK SURFACE SUMMARY

section "18. ATTACK SURFACE SUMMARY"

FOUND=0

grep -Rqi "dropbear" "$EXTRACT_DIR" 2>/dev/null && echo -e "  ${C_RED}→ SSH service detected: Dropbear${RESET}" && FOUND=1
grep -Rqi "telnetd" "$EXTRACT_DIR" 2>/dev/null && echo -e "  ${C_RED}→ Telnet service detected${RESET}" && FOUND=1
grep -Rqi "busybox" "$EXTRACT_DIR" 2>/dev/null && echo -e "  ${C_YELLOW}→ BusyBox detected${RESET}" && FOUND=1
grep -RqiE "boa|lighttpd|uhttpd|httpd" "$EXTRACT_DIR" 2>/dev/null && echo -e "  ${C_YELLOW}→ Embedded web server detected${RESET}" && FOUND=1
find "$EXTRACT_DIR" -type f -name "shadow" 2>/dev/null | grep -q . && echo -e "  ${C_RED}→ Password hashes found (/etc/shadow)${RESET}" && FOUND=1
grep -RqiE "BEGIN (RSA |DSA |EC |OPENSSH )?PRIVATE KEY" "$EXTRACT_DIR" 2>/dev/null && echo -e "  ${C_RED}→ Private key material detected${RESET}" && FOUND=1
grep -RqiE "ssid|psk|wpa_supplicant" "$EXTRACT_DIR" 2>/dev/null && echo -e "  ${C_YELLOW}→ Wireless configuration material detected${RESET}" && FOUND=1

[ "$FOUND" -eq 0 ] && print_empty



# 19. SUMMARY

section "19. SUMMARY"

echo -e "  ${C_GREEN}✔ Firmware analyzed${RESET}"
echo -e "  ${C_GREEN}✔ Filesystems extracted${RESET}"
echo -e "  ${C_GREEN}✔ Password databases checked${RESET}"
echo -e "  ${C_GREEN}✔ Secrets, keys, configs and services scanned${RESET}"
echo ""
echo -e "  ${C_WHITE}${BOLD}Extraction directory:${RESET} ${C_YELLOW}$EXTRACT_DIR${RESET}"
echo ""
