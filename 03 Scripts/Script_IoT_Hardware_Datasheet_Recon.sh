#!/bin/bash

# ============================================================
#  IoT_Hardware_Datasheet_Recon.sh - IoT Chip Identification & Attack Surface
#  TheMalwareGuardian | github.com/TheMalwareGuardian
# ============================================================

CHIP="$1"



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



# Validation

if [ -z "$CHIP" ]; then
	echo -e "${C_RED}${BOLD}Usage:${RESET} $0 <chip_part_number>"
	exit 1
fi



# Normalize

CHIP_UPPER=$(echo "$CHIP" | tr '[:lower:]' '[:upper:]')



# Banner

echo ""
echo -e "${C_MAGENTA}${BOLD}"
echo "   ██╗  ██╗ █████╗ ██████╗ ██████╗ ██╗    ██╗ █████╗ ██████╗ ███████╗"
echo "   ██║  ██║██╔══██╗██╔══██╗██╔══██╗██║    ██║██╔══██╗██╔══██╗██╔════╝"
echo "   ███████║███████║██████╔╝██████╔╝██║ █╗ ██║███████║██████╔╝█████╗  "
echo "   ██╔══██║██╔══██║██╔══██╗██╔══██╗██║███╗██║██╔══██║██╔══██╗██╔══╝  "
echo "   ██║  ██║██║  ██║██║  ██║██║  ██║╚███╔███╔╝██║  ██║██║  ██║███████╗"
echo "   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝"
echo -e "${RESET}"

echo -e "  ${C_DARK}IoT Hardware Recon  •  TheMalwareGuardian${RESET}"
echo ""
echo -e "  ${C_WHITE}${BOLD}Chip :${RESET}  ${C_YELLOW}${BOLD}$CHIP${RESET}"
echo ""



# 1. CHIP IDENTIFICATION

section "1. CHIP IDENTIFICATION"

TYPE="Unknown"
CATEGORY="Unknown"
VENDOR="Unknown"
INTERFACE="Unknown"


# Flash
if [[ "$CHIP_UPPER" =~ (25Q|W25|MX25|GD25|EN25|SST25) ]]; then
	TYPE="SPI Flash"
	CATEGORY="Storage"
	INTERFACE="SPI"
fi

if [[ "$CHIP_UPPER" =~ (MT29F|K9F|TC58|H27U) ]]; then
	TYPE="NAND Flash"
	CATEGORY="Storage"
	INTERFACE="Parallel / SPI"
fi

# RAM
if [[ "$CHIP_UPPER" =~ (DDR|SDRAM|LPDDR|IS42|MT48) ]]; then
	TYPE="RAM"
	CATEGORY="Memory"
	INTERFACE="Memory Bus"
fi

# MCU
if [[ "$CHIP_UPPER" =~ (STM32|STM8) ]]; then
	TYPE="Microcontroller"
	CATEGORY="Processing"
	VENDOR="STMicroelectronics"
	INTERFACE="SWD / JTAG / UART"
fi

if [[ "$CHIP_UPPER" =~ (ESP32|ESP8266) ]]; then
	TYPE="WiFi Microcontroller"
	CATEGORY="Processing"
	VENDOR="Espressif"
	INTERFACE="UART / SPI"
fi

# SoC
if [[ "$CHIP_UPPER" =~ (MT7628|MT7688|MT7620) ]]; then
	TYPE="SoC"
	CATEGORY="Processing"
	VENDOR="MediaTek"
	INTERFACE="UART / JTAG / SPI"
fi

if [[ "$CHIP_UPPER" =~ (AR9331|QCA9531|QCA9558) ]]; then
	TYPE="SoC"
	CATEGORY="Processing"
	VENDOR="Qualcomm Atheros"
	INTERFACE="UART / JTAG"
fi

# Wireless
if [[ "$CHIP_UPPER" =~ (RTL8188|RTL8192|RTL8723) ]]; then
	TYPE="WiFi Chip"
	CATEGORY="Wireless"
	VENDOR="Realtek"
	INTERFACE="SDIO / USB"
fi

# Vendor Fallback
[[ "$CHIP_UPPER" =~ ^W25 ]] && VENDOR="Winbond"
[[ "$CHIP_UPPER" =~ ^MX ]] && VENDOR="Macronix"
[[ "$CHIP_UPPER" =~ ^GD ]] && VENDOR="GigaDevice"

kv "$C_CYAN" "Vendor" "$VENDOR"
kv "$C_GREEN" "Type" "$TYPE"
kv "$C_YELLOW" "Category" "$CATEGORY"
kv "$C_MAGENTA" "Interface" "$INTERFACE"



# 2. DATASHEET DISCOVERY

section "2. DATASHEET DISCOVERY"

SEARCH_URL="https://www.google.com/search?q=${CHIP}+datasheet"
kv "$C_BLUE" "Search URL" "$SEARCH_URL"



# 3. ATTACK SURFACE

section "3. ATTACK SURFACE"

ATTACKS=()

if [ "$TYPE" = "SPI Flash" ]; then
	ATTACKS+=("Firmware Dump via SPI")
	ATTACKS+=("Firmware Modification")
	ATTACKS+=("Credential Extraction")
fi

if [ "$TYPE" = "NAND Flash" ]; then
	ATTACKS+=("Full Firmware Dump")
fi

if [ "$CATEGORY" = "Processing" ]; then
	ATTACKS+=("UART Console Access")
	ATTACKS+=("Bootloader Interaction")
fi

if [[ "$INTERFACE" =~ JTAG ]]; then
	ATTACKS+=("Full Memory Access via JTAG")
fi

if [ "$CATEGORY" = "Wireless" ]; then
	ATTACKS+=("RF Sniffing")
	ATTACKS+=("Protocol Exploitation")
fi

for a in "${ATTACKS[@]}"; do
	echo "    - $a"
done



# 4. TOOLING

section "4. RECOMMENDED TOOLS"

TOOLS=()

if [ "$TYPE" = "SPI Flash" ]; then
	TOOLS+=("CH341A Programmer")
	TOOLS+=("flashrom")
fi

if [[ "$INTERFACE" =~ UART ]]; then
	TOOLS+=("USB-to-TTL Adapter")
fi

if [[ "$INTERFACE" =~ JTAG ]]; then
	TOOLS+=("OpenOCD")
	TOOLS+=("JTAGulator")
fi

if [ "$CATEGORY" = "Wireless" ]; then
	TOOLS+=("SDR (HackRF / RTL-SDR)")
fi

for t in "${TOOLS[@]}"; do
	echo "    - $t"
done



# DONE

echo ""
echo -e "${C_MAGENTA}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
printf "${C_MAGENTA}${BOLD}║${RESET}  ${C_GREEN}${BOLD}%-52s${RESET}${C_MAGENTA}${BOLD}║${RESET}\n" "Hardware Recon Complete."
echo -e "${C_MAGENTA}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
