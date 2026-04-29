#!/bin/bash

# ============================================================
#  IoT_Firmware_AutoPwn_Analyzer.sh - Firmware ZIP Cracker
#  TheMalwareGuardian | github.com/TheMalwareGuardian
# ============================================================

TARGET="$1"
WORDLIST="$2"

OUTDIR="firmware_crack_output"
CLEAN_ZIP="$OUTDIR/clean_firmware.zip"
FULLHASH="$OUTDIR/full_hash.txt"
HASHFILE="$OUTDIR/ziphash.txt"
CRACKED="$OUTDIR/cracked.txt"
UNZIP_DIR="$OUTDIR/unzipped"



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
	echo -e "${C_MAGENTA}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
	printf "${C_MAGENTA}${BOLD}║${RESET}  ${C_WHITE}${BOLD}%-52s${RESET}${C_MAGENTA}${BOLD}║${RESET}\n" "$1"
	echo -e "${C_MAGENTA}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
	echo ""
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
echo -e "  ${C_DARK}Firmware ZIP Password Recovery • TheMalwareGuardian${RESET}"
echo ""
echo -e "  ${C_WHITE}${BOLD}Target:${RESET} ${C_YELLOW}${BOLD}$TARGET${RESET}"
echo ""



# Validation

if [ -z "$TARGET" ]; then
	echo -e "${C_RED}Usage:${RESET} $0 <firmware.zip> [wordlist]"
	exit 1
fi

if [ ! -f "$TARGET" ]; then
	echo -e "${C_RED}[ERROR] File not found${RESET}"
	exit 1
fi

mkdir -p "$OUTDIR" "$UNZIP_DIR"
rm -f "$CLEAN_ZIP" "$FULLHASH" "$HASHFILE" "$CRACKED"



# 1. FILE IDENTIFICATION

section "1. FILE IDENTIFICATION"

echo -e "  ${C_WHITE}$(file -b "$TARGET")${RESET}"



# 2. ZIP NORMALIZATION

section "2. ZIP NORMALIZATION"

OFFSET=$(grep -aob $'PK\003\004' "$TARGET" | head -n1 | cut -d: -f1)

if [ -z "$OFFSET" ]; then
	echo -e "  ${C_RED}[!] ZIP header not found${RESET}"
	exit 1
fi

echo -e "  ${C_CYAN}[+] ZIP start offset:${RESET} $OFFSET"

dd if="$TARGET" of="$CLEAN_ZIP" bs=1 skip="$OFFSET" status=none

echo -e "  ${C_GREEN}[+] Clean ZIP:${RESET} $CLEAN_ZIP"



# 3. HASH EXTRACTION

section "3. HASH EXTRACTION"

echo -e "  ${C_CYAN}[+] Running zip2john...${RESET}"

zip2john -c "$CLEAN_ZIP" > "$FULLHASH" 2>/dev/null

if [ ! -s "$FULLHASH" ]; then
	echo -e "  ${C_RED}[!] zip2john produced no output${RESET}"
	exit 1
fi

# Extract only the hash part
cut -d ':' -f2 "$FULLHASH" | grep -a '\$pkzip' > "$HASHFILE"

if [ ! -s "$HASHFILE" ]; then
	echo -e "  ${C_RED}[!] Failed to isolate usable hash${RESET}"
	echo -e "  ${C_DARK}Debug:${RESET} check $FULLHASH"
	exit 1
fi

echo -e "  ${C_GREEN}[+] Hash extracted successfully${RESET}"



# 4. PASSWORD CRACKING

section "4. PASSWORD CRACKING"

if [ -n "$WORDLIST" ] && [ -f "$WORDLIST" ]; then

	echo -e "  ${C_YELLOW}[MODE] Dictionary attack${RESET}"
	echo -e "  ${C_YELLOW}Wordlist:${RESET} $WORDLIST"

	hashcat -m 17230 -a 0 -o "$CRACKED" "$HASHFILE" "$WORDLIST" --show

else

	echo -e "  ${C_YELLOW}[MODE] Brute-force fallback${RESET}"
	echo -e "  ${C_DARK}No wordlist provided → using mask attack${RESET}"

	CHARSET="$OUTDIR/charset.hcchr"
	echo "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" > "$CHARSET"

	hashcat -m 17230 -a 3 --potfile-disable -o "$CRACKED" -1 "$CHARSET" "$HASHFILE" '?1?1?1?1?1?1?1?1'

fi



# 5. RESULT

if [ ! -s "$CRACKED" ]; then
	echo -e "  ${C_RED}[!] Password not recovered${RESET}"
	exit 1
fi

PASSWORD=$(awk -F: '{print $NF}' "$CRACKED" | head -n1)

echo -e "  ${C_GREEN}[+] Password:${RESET} ${BOLD}$PASSWORD${RESET}"



# 6. UNZIP

section "5. EXTRACTION"

unzip -P "$PASSWORD" "$CLEAN_ZIP" -d "$UNZIP_DIR" >/dev/null 2>&1

if [ $? -ne 0 ]; then
	echo -e "  ${C_RED}[!] Unzip failed${RESET}"
	exit 1
fi

echo -e "  ${C_GREEN}[+] Extracted to:${RESET} $UNZIP_DIR"



# DONE

echo ""
echo -e "${C_MAGENTA}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
printf "${C_MAGENTA}${BOLD}║${RESET}  ${C_GREEN}${BOLD}%-52s${RESET}${C_MAGENTA}${BOLD}║${RESET}\n" "Firmware Cracking Complete."
echo -e "${C_MAGENTA}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
