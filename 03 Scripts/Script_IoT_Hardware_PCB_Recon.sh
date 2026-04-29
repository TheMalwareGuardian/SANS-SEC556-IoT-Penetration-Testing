#!/bin/bash

# ============================================================
#  IoT_Hardware_PCB_Recon.sh - PCB Silkscreen & Component Identification
#  TheMalwareGuardian | github.com/TheMalwareGuardian
# ============================================================

INPUT_FILE="$1"



# Colors

BOLD=$'\033[1m'
RESET=$'\033[0m'
C_GREEN=$'\033[1;32m'
C_RED=$'\033[1;31m'
C_YELLOW=$'\033[1;33m'
C_BLUE=$'\033[1;34m'
C_MAGENTA=$'\033[1;35m'
C_CYAN=$'\033[1;36m'
C_WHITE=$'\033[1;37m'
C_DARK=$'\033[2;37m'



# Validation

if [ -z "$INPUT_FILE" ]; then
	echo -e "${C_RED}${BOLD}Usage:${RESET} $0 <pcb_text_file>"
	exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
	echo -e "${C_RED}File not found${RESET}"
	exit 1
fi



# Helpers

add_found() {
	FOUND+=("$1")
}

is_found() {
	local item="$1"
	for f in "${FOUND[@]}"; do
		[ "$f" = "$item" ] && return 0
	done
	return 1
}

print_empty() {
	echo -e "  ${C_DARK}No entries identified.${RESET}"
}



# Load Data

PCB=$(cat "$INPUT_FILE")

# Standard PCB designators
ALL_COMPONENTS=$(echo "$PCB" | tr '[:lower:]' '[:upper:]' | grep -Eo '\b[A-Z]{1,4}[0-9]+\b' | sort -u)

# All tokens (to detect unknown stuff)
ALL_TOKENS=$(echo "$PCB" | tr '[:lower:]' '[:upper:]' | grep -Eo '\b[A-Z0-9_+-]{2,}\b' | sort -u)

FOUND=()



# Banner

echo ""
echo -e "${C_MAGENTA}${BOLD}"
echo "   ██████╗  ██████╗ ██████╗ "
echo "   ██╔══██╗██╔════╝██╔══██╗"
echo "   ██████╔╝██║     ██████╔╝"
echo "   ██╔═══╝ ██║     ██╔══██╗"
echo "   ██║     ╚██████╗██████╔╝"
echo "   ╚═╝      ╚═════╝╚═════╝ "
echo -e "${RESET}"
echo -e "  ${C_DARK}PCB Hardware Recon • TheMalwareGuardian${RESET}"
echo ""
echo -e "  ${C_WHITE}${BOLD}Input:${RESET} ${C_YELLOW}${BOLD}$INPUT_FILE${RESET}"
echo ""



# 1. PASSIVE COMPONENTS

echo -e "${C_BLUE}${BOLD}[+] Passive Components${RESET}"
PRINTED=0

while read -r x; do
	[ -z "$x" ] && continue
	echo -e "  ${C_WHITE}$x${RESET} → Resistor"
	add_found "$x"
	PRINTED=1
done < <(echo "$ALL_COMPONENTS" | grep '^R[0-9]\+')

while read -r x; do
	[ -z "$x" ] && continue
	echo -e "  ${C_WHITE}$x${RESET} → Capacitor"
	add_found "$x"
	PRINTED=1
done < <(echo "$ALL_COMPONENTS" | grep '^C[0-9]\+')

while read -r x; do
	[ -z "$x" ] && continue
	echo -e "  ${C_WHITE}$x${RESET} → Inductor"
	add_found "$x"
	PRINTED=1
done < <(echo "$ALL_COMPONENTS" | grep '^L[0-9]\+')

while read -r x; do
	[ -z "$x" ] && continue
	echo -e "  ${C_WHITE}$x${RESET} → Diode"
	add_found "$x"
	PRINTED=1
done < <(echo "$ALL_COMPONENTS" | grep '^D[0-9]\+')

[ "$PRINTED" -eq 0 ] && print_empty
echo ""



# 2. ACTIVE COMPONENTS

echo -e "${C_BLUE}${BOLD}[+] Active Components${RESET}"
PRINTED=0

while read -r x; do
	[ -z "$x" ] && continue
	echo -e "  ${C_WHITE}$x${RESET} → IC / Chip"
	add_found "$x"
	PRINTED=1
done < <(echo "$ALL_COMPONENTS" | grep '^U[0-9]\+')

while read -r x; do
	[ -z "$x" ] && continue
	echo -e "  ${C_WHITE}$x${RESET} → Transistor / MOSFET"
	add_found "$x"
	PRINTED=1
done < <(echo "$ALL_COMPONENTS" | grep '^Q[0-9]\+')

[ "$PRINTED" -eq 0 ] && print_empty
echo ""



# 3. CONNECTORS

echo -e "${C_CYAN}${BOLD}[+] Connectors & Interfaces${RESET}"
PRINTED=0

while read -r x; do
	[ -z "$x" ] && continue
	echo -e "  ${C_WHITE}$x${RESET} → Connector / Header"
	add_found "$x"
	PRINTED=1
done < <(echo "$ALL_COMPONENTS" | grep '^J[0-9]\+')

[ "$PRINTED" -eq 0 ] && print_empty
echo ""



# 4. TEST POINTS

echo -e "${C_YELLOW}${BOLD}[+] Test Points & Debug${RESET}"
PRINTED=0

while read -r x; do
	[ -z "$x" ] && continue
	echo -e "  ${C_WHITE}$x${RESET} → Test Point (DEBUG GOLD)"
	add_found "$x"
	PRINTED=1
done < <(echo "$ALL_COMPONENTS" | grep '^TP[0-9]\+')

[ "$PRINTED" -eq 0 ] && print_empty
echo ""



# 5. CLOCK / CRYSTALS

echo -e "${C_MAGENTA}${BOLD}[+] Clock / Timing${RESET}"
PRINTED=0

while read -r x; do
	[ -z "$x" ] && continue
	echo -e "  ${C_WHITE}$x${RESET} → Crystal / Oscillator"
	add_found "$x"
	PRINTED=1
done < <(echo "$ALL_COMPONENTS" | grep '^X[0-9]\+')

[ "$PRINTED" -eq 0 ] && print_empty
echo ""



# 6. SIGNAL DETECTION (FIXED)

echo -e "${C_GREEN}${BOLD}[+] Signal Indicators${RESET}"
PRINTED=0

check_signal() {
	local pattern="$1"
	local label="$2"

	if echo "$PCB" | grep -qiE "\b($pattern)\b"; then
		echo "  $label"
		PRINTED=1

		for token in $ALL_TOKENS; do
			if echo "$token" | grep -qiE "^($pattern)$"; then
				add_found "$token"
			fi
		done
	fi
}

check_signal "UART" "UART detected"
check_signal "TX|TXD" "TX pin found"
check_signal "RX|RXD" "RX pin found"
check_signal "GND|VSS" "Ground reference"
check_signal "VCC|VDD|3V3|5V" "Power rail"
check_signal "JTAG" "JTAG detected"
check_signal "SPI" "SPI detected"
check_signal "I2C" "I2C detected"

[ "$PRINTED" -eq 0 ] && print_empty
echo ""



# 7. UNKNOWN ITEMS

echo -e "${C_RED}${BOLD}[+] Unknown / Unclassified Items${RESET}"
PRINTED=0

for token in $ALL_TOKENS; do

	if is_found "$token"; then
		continue
	fi

	echo -e "  ${C_WHITE}$token${RESET} → UNKNOWN (Investigate)"
	PRINTED=1

done

[ "$PRINTED" -eq 0 ] && print_empty
echo ""



# 8. ATTACK SURFACE SUMMARY

echo -e "${C_RED}${BOLD}[+] Attack Surface Summary${RESET}"

echo "$PCB" | grep -qi "UART" && echo "  → UART access (shell/debug)"
echo "$PCB" | grep -qi "JTAG" && echo "  → JTAG full control"
echo "$PCB" | grep -qi "SPI" && echo "  → Flash extraction"
echo "$PCB" | grep -qi "ANT" && echo "  → RF attack surface"
echo "$ALL_COMPONENTS" | grep -q '^J' && echo "  → External connectors"

echo ""
echo -e "${C_MAGENTA}${BOLD}=== Recon Complete ===${RESET}"
echo ""
