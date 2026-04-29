#!/bin/bash

# ============================================================
#  IoT_PCAP_Firmware_Extractor.sh - Firmware Recovery
#  TheMalwareGuardian | github.com/TheMalwareGuardian
# ============================================================

PCAP="$1"
OUTDIR="firmware_output"



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



# Validation

if [ -z "$PCAP" ]; then
	echo -e "${C_RED}${BOLD}Usage:${RESET} $0 <pcap_file>"
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

mkdir -p "$OUTDIR"



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
echo -e "  ${C_DARK}IoT Firmware Extraction  •  TheMalwareGuardian${RESET}"
echo ""
echo -e "  ${C_WHITE}${BOLD}Target:${RESET}  ${C_YELLOW}${BOLD}$PCAP${RESET}"
echo ""



# 1. Protocol Detection

section "1. PROTOCOL DETECTION"

HTTP=$(tshark -r "$PCAP" -Y http 2>/dev/null | wc -l)
FTP=$(tshark -r "$PCAP" -Y ftp 2>/dev/null | wc -l)
TFTP=$(tshark -r "$PCAP" -Y tftp 2>/dev/null | wc -l)

printf "  ${C_CYAN}HTTP packets :${RESET}  %s\n" "$HTTP"
printf "  ${C_CYAN}FTP packets  :${RESET}  %s\n" "$FTP"
printf "  ${C_CYAN}TFTP packets :${RESET}  %s\n" "$TFTP"



# 2. Object Extraction

section "2. OBJECT EXTRACTION"

echo -e "  ${C_BLUE}[*] Extracting HTTP objects...${RESET}"
tshark -Q -r "$PCAP" --export-objects http,"$OUTDIR" 2>/dev/null

echo -e "  ${C_BLUE}[*] Extracting FTP objects...${RESET}"
tshark -Q -r "$PCAP" --export-objects ftp-data,"$OUTDIR" 2>/dev/null

echo -e "  ${C_BLUE}[*] Extracting TFTP objects...${RESET}"
tshark -Q -r "$PCAP" --export-objects tftp,"$OUTDIR" 2>/dev/null



# 3. Firmware Candidates

section "3. FIRMWARE CANDIDATES"

for f in "$OUTDIR"/*; do
	[ -f "$f" ] || continue
	size=$(stat -c%s "$f")

	if [ "$size" -gt 1000000 ]; then
		printf "  ${C_GREEN}%-40s${RESET}  (%s bytes)\n" "$f" "$size"
	fi
done



# 4. FILE ANALYSIS
section "4. FILE ANALYSIS"

kv() {
	printf "    ${1}◆${RESET}  ${C_WHITE}%-22s${RESET}  ${1}${BOLD}%s${RESET}\n" "$2" "$3"
}

for f in "$OUTDIR"/*; do
	[ -f "$f" ] || continue

	size=$(stat -c%s "$f")
	[ "$size" -lt 1000000 ] && continue

	echo -e "  ${C_CYAN}${BOLD}Target:${RESET} ${C_WHITE}$f${RESET}"

	# FILE TYPE (clean)
	FILE_TYPE=$(file -b "$f")
	kv "$C_GREEN" "File Type" "$FILE_TYPE"

	# SIZE
	kv "$C_YELLOW" "Size" "$size bytes"

	# BINWALK (cleaned)
	if command -v binwalk &>/dev/null; then
		BW=$(binwalk "$f" 2>/dev/null | grep -v "DECIMAL" | head -n 3)

		if [ -n "$BW" ]; then
			echo -e "    ${C_MAGENTA}◆${RESET}  ${C_WHITE}Signatures${RESET}"
			echo "$BW" | while read -r line; do
				echo -e "      ${C_DARK}$line${RESET}"
			done
		else
			kv "$C_MAGENTA" "Signatures" "None detected"
		fi
	fi

	echo ""
done



# 5. String Intelligence

section "5. STRING INTELLIGENCE"

for f in "$OUTDIR"/*; do
	[ -f "$f" ] || continue
	size=$(stat -c%s "$f")
	[ "$size" -lt 1000000 ] && continue

	echo -e "  ${C_YELLOW}${BOLD}$f${RESET}"

	strings "$f" | grep -Ei "password|admin|root|http|firmware|config" | head -n 10

	echo ""
done

# Done

echo ""
echo -e "${C_MAGENTA}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
printf "${C_MAGENTA}${BOLD}║${RESET}  ${C_GREEN}${BOLD}%-52s${RESET}${C_MAGENTA}${BOLD}║${RESET}\n" "Firmware Extraction Complete."
echo -e "${C_MAGENTA}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
