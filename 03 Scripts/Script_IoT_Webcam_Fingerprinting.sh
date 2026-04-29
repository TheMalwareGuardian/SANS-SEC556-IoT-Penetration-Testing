#!/bin/bash

# ============================================================
#  IoT_Webcam_Fingerprinting.sh - IoT Foscam HD IP Camera
#  TheMalwareGuardian | github.com/TheMalwareGuardian
# ============================================================

TARGET="$1"
PORT="$2"
USER="$3"
PASS="$4"



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

kv() {
	printf "    ${1}◆${RESET}  ${C_WHITE}%-22s${RESET}  ${1}${BOLD}%s${RESET}\n" "$2" "$3"
}

check_dep() {
	if ! command -v "$1" &>/dev/null; then
		echo -e "${C_RED}[ERROR]${RESET} Required: ${BOLD}$1${RESET}"
		exit 1
	fi
}



# Validation

if [ -z "$TARGET" ] || [ -z "$USER" ] || [ -z "$PASS" ]; then
	echo -e "${C_RED}${BOLD}Usage:${RESET} $0 <target> <port> <user> <pass>"
	exit 1
fi

check_dep curl

BASE_URL="http://$TARGET:$PORT"
URL="$BASE_URL/cgi-bin/CGIProxy.fcgi"



# Banner

echo ""
echo -e "${C_MAGENTA}${BOLD}"
echo "   ██╗    ██╗███████╗██████╗  ██████╗ █████╗ ███╗   ███╗"
echo "   ██║    ██║██╔════╝██╔══██╗██╔════╝██╔══██╗████╗ ████║"
echo "   ██║ █╗ ██║█████╗  ██████╔╝██║     ███████║██╔████╔██║"
echo "   ██║███╗██║██╔══╝  ██╔══██╗██║     ██╔══██║██║╚██╔╝██║"
echo "   ╚███╔███╔╝███████╗██████╔╝╚██████╗██║  ██║██║ ╚═╝ ██║"
echo "    ╚══╝╚══╝ ╚══════╝╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝"
echo -e "${RESET}"

echo -e "  ${C_DARK}IoT Webcam Fingerprinting  •  TheMalwareGuardian${RESET}"
echo ""
echo -e "  ${C_WHITE}${BOLD}Target :${RESET}  ${C_YELLOW}${BOLD}$TARGET${RESET}"
echo -e "  ${C_WHITE}${BOLD}User   :${RESET}  ${C_CYAN}$USER${RESET}"
echo ""



# 1. AUTH CHECK

section "1. AUTHENTICATION CHECK"

RESP=$(curl -s "$URL?usr=$USER&pwd=$PASS&cmd=login")

RESULT=$(echo "$RESP" | grep -oP '(?<=<result>).*?(?=</result>)')

if [ "$RESULT" = "0" ]; then
	echo -e "  ${C_GREEN}Authentication successful${RESET}"
else
	echo -e "  ${C_RED}${BOLD}Authentication failed${RESET}"
	exit 1
fi



# 2. HTML FINGERPRINTING

section "2. HTML FINGERPRINTING"

# Html
for path in "/login.html" "/" "/index.html"; do
	HTML=$(curl -s "$BASE_URL$path")
	echo "$HTML" | grep -qi "<title>" && break
done

# Title
TITLE=$(echo "$HTML" | tr -d '\n' | sed -n 's/.*<title>\(.*\)<\/title>.*/\1/p')
[ -z "$TITLE" ] && TITLE="Unknown"

# Vendor
VENDOR="Unknown"
if echo "$HTML" | grep -qi "FoscamFlashPlayer"; then
	VENDOR="Foscam OEM"
elif echo "$HTML" | grep -qi "IPCWebComponents"; then
	VENDOR="Foscam OEM"
elif echo "$HTML" | grep -qi "foscam"; then
	VENDOR="Foscam"
elif echo "$HTML" | grep -qi "ipcam-regplugin"; then
	VENDOR="Generic IPCam"
fi

# Output
kv "$C_CYAN" "Page Title" "$TITLE"
kv "$C_GREEN" "Vendor" "$VENDOR"



# 3. DEVICE ENUMERATION

section "3. DEVICE ENUMERATION"

COMMANDS=(
"getDevInfo"
"getDevState"
"getDevName"
"getUserList"
"getWifiList"
"getSystemInfo"
)

for cmd in "${COMMANDS[@]}"; do

	echo ""
	echo -e "  ${C_YELLOW}${BOLD}▸ $cmd${RESET}"

	RESP=$(curl -s "$URL?usr=$USER&pwd=$PASS&cmd=$cmd")

	RESULT=$(echo "$RESP" | grep -oP '(?<=<result>).*?(?=</result>)')

	if [ "$RESULT" != "0" ]; then
		echo -e "    ${C_RED}✘ Failed${RESET}"
		continue
	fi

	DATA=$(echo "$RESP" | grep -oP '<\w+>[^<]+</\w+>' | grep -v "<result>")

	if [ -z "$DATA" ]; then
		echo -e "    ${C_DARK}✔ Valid but no data returned${RESET}"
	else
		echo -e "    ${C_GREEN}✔ Data:${RESET}"
		echo "$DATA" | while read -r line; do
			echo -e "    ${C_WHITE}$line${RESET}"
		done
	fi

done



# 4. STREAM

section "4. STREAMING INFORMATION"

RTSP="rtsp://$USER:$PASS@$TARGET:554/videoMain"

kv "$C_MAGENTA" "RTSP URL" "$RTSP"



# DONE

echo ""
echo -e "${C_MAGENTA}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
printf "${C_MAGENTA}${BOLD}║${RESET}  ${C_GREEN}${BOLD}%-52s${RESET}${C_MAGENTA}${BOLD}║${RESET}\n" "Fingerprinting complete."
echo -e "${C_MAGENTA}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
