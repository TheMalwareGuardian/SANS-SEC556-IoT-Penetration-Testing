#!/bin/bash

# ============================================================
#  IoT_PCAP_Zigbee_Recon.sh - Zigbee Network Recon & Profiling
#  TheMalwareGuardian | github.com/TheMalwareGuardian
# ============================================================


PCAP="$1"
OUTDIR="zigbee_recon_output"
BASE="$(basename "$PCAP")"



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

# Prints a styled section header box
section() {
	echo ""
	echo -e "${C_CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
	printf "${C_CYAN}${BOLD}║${RESET}  ${C_WHITE}${BOLD}%-52s${RESET}${C_CYAN}${BOLD}║${RESET}\n" "$1"
	echo -e "${C_CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
	echo ""
}

# Used when a section produces no results
print_empty() {
	echo -e "  ${C_DARK}No entries identified.${RESET}"
}

# Runs a tshark display filter and returns the frame count.
count_filter() {
	tshark -r "$PCAP" -Y "$1" 2>/dev/null | wc -l | xargs
}

# Collapses multiple spaces and tabs in a raw tshark output line so it prints cleanly without alignment issues
clean_line() {
	echo "$1" | tr '\t' ' ' | sed 's/  */ /g'
}



# Normalizes any value to lowercase 0x-prefixed 4-digit hex.
normalize_hex() {
	local v
	v=$(echo "$1" | tr '[:upper:]' '[:lower:]' | xargs)
	# Already 0x-prefixed - normalize to 4 digits (0x01 → 0x0001)
	if echo "$v" | grep -qE '^0x[0-9a-f]+$'; then
		printf '0x%04x' "$(( v ))"
	# Plain decimal integer - convert to 0x-prefixed 4-digit hex
	elif echo "$v" | grep -qE '^[0-9]+$'; then
		printf '0x%04x' "$v"
	# Anything else (empty, malformed) - return unchanged
	else
		echo "$v"
	fi
}



# IEEE 802.15.4 MAC frame type.
frame_type_name() {
	local v
	v=$(normalize_hex "$1")
	case "$v" in
		0x0000) echo "Beacon" ;;
		0x0001) echo "Data" ;;
		0x0002) echo "Acknowledgment" ;;
		0x0003) echo "MAC Command" ;;
		*) echo "Unknown ($1)" ;;
	esac
}



# Zigbee Application Profile IDs
profile_name() {
	local v
	v=$(normalize_hex "$1")
	case "$v" in
		0x0000) echo "Zigbee Device Profile (ZDP)" ;;
		0x0104) echo "Home Automation" ;;
		0x0105) echo "Commercial Building Automation" ;;
		0x0107) echo "Telecom Applications" ;;
		0x0108) echo "Personal Home and Hospital Care" ;;
		0x0109) echo "Advanced Metering Infrastructure" ;;
		0xc05e) echo "Zigbee Light Link" ;;
		0xc25c) echo "Control4 / Vendor" ;;
		0xc25d) echo "Control4 / Vendor" ;;
		*)      echo "Unknown / Vendor-Specific" ;;
	esac
}



# ZDP (Zigbee Device Profile) cluster IDs
zdp_cluster_name() {
	local v
	v=$(normalize_hex "$1")
	case "$v" in
		0x0000) echo "NWK Address Request" ;;
		0x0001) echo "IEEE Address Request" ;;
		0x0002) echo "Node Descriptor Request" ;;
		0x0003) echo "Power Descriptor Request" ;;
		0x0004) echo "Simple Descriptor Request" ;;
		0x0005) echo "Active Endpoints Request" ;;
		0x0006) echo "Match Descriptor Request" ;;
		0x0010) echo "Complex Descriptor Request" ;;
		0x0011) echo "User Descriptor Request" ;;
		0x0013) echo "Device Announce" ;;
		0x0020) echo "End Device Bind Request" ;;
		0x0021) echo "Bind Request" ;;
		0x0022) echo "Unbind Request" ;;
		0x0036) echo "Mgmt Leave Request" ;;
		0x0037) echo "Mgmt Direct Join Request" ;;
		0x0038) echo "Mgmt Permit Join Request" ;;
		0x003a) echo "Mgmt NWK Update Request" ;;
		0x8000) echo "NWK Address Response" ;;
		0x8001) echo "IEEE Address Response" ;;
		0x8002) echo "Node Descriptor Response" ;;
		0x8003) echo "Power Descriptor Response" ;;
		0x8004) echo "Simple Descriptor Response" ;;
		0x8005) echo "Active Endpoints Response" ;;
		0x8006) echo "Match Descriptor Response" ;;
		0x8020) echo "End Device Bind Response" ;;
		0x8021) echo "Bind Response" ;;
		0x8022) echo "Unbind Response" ;;
		0x8031) echo "Mgmt LQI Response" ;;
		0x8036) echo "Mgmt Leave Response" ;;
		0x8038) echo "Mgmt Permit Join Response" ;;
		0x803a) echo "Mgmt NWK Update Notify" ;;
		*)      echo "Unknown ZDP ($(normalize_hex "$1"))" ;;
	esac
}



# Home Automation / ZCL cluster IDs
ha_cluster_name() {
	local v
	v=$(normalize_hex "$1")
	case "$v" in
		# General / foundation clusters
		0x0000) echo "Basic" ;;
		0x0001) echo "Power Configuration" ;;
		0x0002) echo "Device Temperature" ;;
		0x0003) echo "Identify" ;;
		0x0004) echo "Groups" ;;
		0x0005) echo "Scenes" ;;
		0x0006) echo "On/Off" ;;
		0x0007) echo "On/Off Switch Config" ;;
		0x0008) echo "Level Control" ;;
		0x0009) echo "Alarms" ;;
		0x000a) echo "Time" ;;
		0x000b) echo "RSSI Location" ;;
		0x000c) echo "Analog Input" ;;
		0x000d) echo "Analog Output" ;;
		0x000e) echo "Analog Value" ;;
		0x000f) echo "Binary Input" ;;
		0x0010) echo "Binary Output" ;;
		0x0011) echo "Binary Value" ;;
		0x0013) echo "Multistate Input" ;;
		0x0019) echo "OTA Upgrade" ;;
		0x0020) echo "Poll Control" ;;
		0x0021) echo "Green Power Proxy" ;;
		# Closure / HVAC clusters
		0x0101) echo "Door Lock" ;;
		0x0102) echo "Window Covering" ;;
		0x0200) echo "Pump Configuration" ;;
		0x0201) echo "Thermostat" ;;
		0x0202) echo "Fan Control" ;;
		0x0204) echo "Thermostat UI Config" ;;
		# Lighting clusters
		0x0300) echo "Color Control" ;;
		0x0301) echo "Ballast Configuration" ;;
		# Measurement / sensing clusters
		0x0400) echo "Illuminance Measurement" ;;
		0x0401) echo "Illuminance Level Sensing" ;;
		0x0402) echo "Temperature Measurement" ;;
		0x0403) echo "Pressure Measurement" ;;
		0x0404) echo "Flow Measurement" ;;
		0x0405) echo "Humidity Measurement" ;;
		0x0406) echo "Occupancy Sensing" ;;
		# IAS (Intruder Alarm System) clusters
		0x0500) echo "IAS Zone" ;;
		0x0501) echo "IAS ACE" ;;
		0x0502) echo "IAS WD" ;;
		# Protocol tunnel
		0x0600) echo "Generic Tunnel" ;;
		# Smart energy clusters
		0x0700) echo "Price" ;;
		0x0701) echo "Demand Response & Load Control" ;;
		0x0702) echo "Simple Metering" ;;
		0x0703) echo "Messaging" ;;
		0x0800) echo "Key Establishment" ;;
		# Electrical measurement
		0x0b04) echo "Electrical Measurement" ;;
		0x0b05) echo "Diagnostics" ;;
		# ZLL
		0x1000) echo "Touchlink Commissioning" ;;
		*)      echo "Unknown / Vendor ($(normalize_hex "$1"))" ;;
	esac
}



# Dispatches cluster name resolution based on the profile
cluster_name_for_profile() {
	local cluster="$1"
	local profile="$2"
	local pnorm
	pnorm=$(normalize_hex "$profile")
	case "$pnorm" in
		0x0000) zdp_cluster_name "$cluster" ;;
		*)      ha_cluster_name  "$cluster" ;;
	esac
}



# Zigbee NWK layer command IDs
nwk_cmd_name() {
	local v
	v=$(normalize_hex "$1")
	case "$v" in
		# Initiates route discovery
		0x0001) echo "Route Request" ;;
		# Response to route request
		0x0002) echo "Route Reply" ;;
		# Reports a routing error
		0x0003) echo "Network Status" ;;
		# Device leaving the network
		0x0004) echo "Leave" ;;
		# Source routing trace
		0x0005) echo "Route Record" ;;
		# Device requesting to rejoin
		0x0006) echo "Rejoin Request" ;;
		# Coordinator/router response
		0x0007) echo "Rejoin Response" ;;
		# Periodic neighbor link quality report
		0x0008) echo "Link Status" ;;
		# PAN ID conflict report
		0x0009) echo "Network Report" ;;
		# PAN ID change notification
		0x000a) echo "Network Update" ;;
		0x000b) echo "End Device Timeout Request" ;;
		0x000c) echo "End Device Timeout Response" ;;
		*)      echo "Unknown ($1)" ;;
	esac
}



# Zigbee APS layer command IDs
aps_cmd_name() {
	local v
	v=$(normalize_hex "$1")
	case "$v" in
		# Symmetric-key key establishment
		0x0001) echo "SKKE-1" ;;
		0x0002) echo "SKKE-2" ;;
		0x0003) echo "SKKE-3" ;;
		0x0004) echo "SKKE-4" ;;
		# ⚠ Carries network/link key
		0x0005) echo "Transport Key" ;;
		# Notifies Trust Center of join/leave
		0x0006) echo "Update Device" ;;
		# Trust Center removes a device
		0x0007) echo "Remove Device" ;;
		# Device requests a key from TC
		0x0008) echo "Request Key" ;;
		# Switches to a new network key
		0x0009) echo "Switch Key" ;;
		# Tunnels another APS command
		0x000e) echo "Tunnel" ;;
		# Key verification challenge
		0x000f) echo "Verify Key" ;;
		# Confirms key verification
		0x0010) echo "Confirm Key" ;;
		*)      echo "Unknown ($1)" ;;
	esac
}



# ZCL global command IDs
zcl_cmd_name() {
	local v
	v=$(normalize_hex "$1")
	case "$v" in
		0x0000) echo "Read Attributes" ;;
		0x0001) echo "Read Attributes Response" ;;
		0x0002) echo "Write Attributes" ;;
		0x0003) echo "Write Attributes Undivided" ;;
		0x0004) echo "Write Attributes Response" ;;
		0x0005) echo "Write Attributes No Response" ;;
		0x0006) echo "Configure Reporting" ;;
		0x0007) echo "Configure Reporting Response" ;;
		0x0008) echo "Read Reporting Configuration" ;;
		0x0009) echo "Read Reporting Cfg Response" ;;
		0x000a) echo "Report Attributes" ;;
		0x000b) echo "Default Response" ;;
		0x000c) echo "Discover Attributes" ;;
		0x000d) echo "Discover Attributes Response" ;;
		0x000e) echo "Read Attr. Structured" ;;
		0x000f) echo "Write Attr. Structured" ;;
		0x0010) echo "Write Attr. Structured Response" ;;
		0x0011) echo "Discover Commands Received" ;;
		0x0012) echo "Discover Commands Rcvd Response" ;;
		0x0013) echo "Discover Commands Generated" ;;
		0x0014) echo "Discover Commands Gen Response" ;;
		0x0015) echo "Discover Attr. Extended" ;;
		0x0016) echo "Discover Attr. Extended Response" ;;
		# Frame type 1 (cluster-specific) - cannot decode without cluster context
		*)      echo "Cluster-Specific ($1)" ;;
	esac
}



# Heuristic device type identification based on Node address, APS profile, ZCL cluster list and Traffic pattern 
device_guess() {
	local node="$1"
	local clusters="$2"
	local profile="$3"
	local sent="${4:-0}"
	local bcast="${5:-0}"
	local recv="${6:-0}"

	# Short address 0x0000 is always assigned to the PAN coordinator
	[ "$node" = "0x0000" ] && { echo "Coordinator / Gateway / Trust Center"; return; }

	local pnorm
	pnorm=$(normalize_hex "$profile")

	# Vendor-specific profiles (Control4, proprietary Zigbee stacks)
	if echo "$pnorm" | grep -qE '^0xc2'; then
		[ "$sent" -gt 50 ] && echo "Vendor Controller / Hub" || echo "Vendor Device (Proprietary Zigbee)"
		return
	fi

	# Normalize the full cluster list once before all grep comparisons
	local cnorm
	cnorm=$(echo "$clusters" | tr ' ' '\n' | while read -r c; do normalize_hex "$c"; done | tr '\n' ' ')

	# Sensor heuristic: low TX count relative to RX suggests a battery-powered end device that reports periodically and is mostly receiving ACKs
	if [ "$sent" -lt 15 ]; then
		echo "$cnorm" | grep -qw "0x0402" && { echo "Temperature sensor"; return; }
		echo "$cnorm" | grep -qw "0x0405" && { echo "Humidity sensor"; return; }
		echo "$cnorm" | grep -qw "0x0406" && { echo "Motion / Occupancy sensor"; return; }
		echo "$cnorm" | grep -qw "0x0400" && { echo "Illuminance sensor"; return; }
		echo "$cnorm" | grep -qw "0x0500" && { echo "IAS Zone / Security sensor"; return; }
		echo "$cnorm" | grep -qw "0x0404" && { echo "Flow sensor"; return; }
		echo "$cnorm" | grep -qw "0x0403" && { echo "Pressure sensor"; return; }
		[ "$recv" -gt "$sent" ]            && { echo "Battery-powered sensor"; return; }
	fi

	# Actuator fingerprinting by cluster
	echo "$cnorm" | grep -qw "0x0300" && { echo "Color light (RGB/RGBW)"; return; }
	if echo "$cnorm" | grep -qw "0x0006"; then
		# 0x0008 (Level Control) alongside On/Off = dimmable
		echo "$cnorm" | grep -qw "0x0008" && { echo "Dimmable light / plug"; return; }
		echo "On/Off device (light / plug)"
		return
	fi
	echo "$cnorm" | grep -qw "0x0101" && { echo "Door lock"; return; }
	echo "$cnorm" | grep -qw "0x0201" && { echo "Thermostat"; return; }
	echo "$cnorm" | grep -qw "0x0202" && { echo "Fan controller"; return; }
	echo "$cnorm" | grep -qw "0x0102" && { echo "Window covering / blind"; return; }

	# Energy / metering
	echo "$cnorm" | grep -qw "0x0702" && { echo "Smart meter"; return; }
	echo "$cnorm" | grep -qw "0x0b04" && { echo "Electrical measurement device"; return; }

	# Router heuristic: high TX + significant broadcast activity.
	# Routers send periodic Link Status broadcasts and relay route requests.
	[ "$bcast" -gt 10 ] && [ "$sent" -gt 20 ] && { echo "Router / relay node"; return; }

	# Fallback by raw traffic volume
	if   [ "$sent" -gt 100 ]; then echo "High-activity node (controller-like)"
	elif [ "$sent" -gt  30 ]; then echo "Active node"
	elif [ "$sent" -lt  10 ]; then echo "Low-activity node (possible end device)"
	else                           echo "Generic Zigbee node"
	fi
}



# Infers the Zigbee network role from traffic behavior, Coordinator (always at address 0x0000), Router (high send count + significant broadcast activity), and End Device (they only transmit their own data)
role_guess() {
	local node="${1:-}"
	local sent="${2:-0}"
	local bcast="${3:-0}"

	[ "$node"  = "0x0000" ]                  && { echo "Coordinator / Trust Center"; return; }
	[ "$sent" -gt 50 ] && [ "$bcast" -gt 5 ] && { echo "Router candidate"; return; }
	[ "$sent" -lt 10 ]                        && { echo "End Device candidate"; return; }
	echo "Zigbee node"
}



# Checks

if [ -z "$PCAP" ]; then
	echo -e "${C_RED}Usage:${RESET} $0 <capture.pcap|.dcf>"
	exit 1
fi

if [ ! -f "$PCAP" ]; then
	echo -e "${C_RED}[ERROR] File not found:${RESET} $PCAP"
	exit 1
fi

if ! command -v tshark &>/dev/null; then
	echo -e "${C_RED}[ERROR] tshark is required. Install: apt install tshark${RESET}"
	exit 1
fi

mkdir -p "$OUTDIR"



# Output file paths

DEVICES_CSV="$OUTDIR/${BASE}.devices.csv"
CLUSTERS_CSV="$OUTDIR/${BASE}.clusters.csv"
EDGES_CSV="$OUTDIR/${BASE}.edges.csv"
REPORT_TXT="$OUTDIR/${BASE}.report.txt"

rm -f "$DEVICES_CSV" "$CLUSTERS_CSV" "$EDGES_CSV" "$REPORT_TXT"

FILE_INFO=$(file "$PCAP")



# Detect Daintree SNA / ASCII DCF format.
# DCF (Data Capture File) is a text-based capture format produced by the Daintree SNA tool, commonly used for Zigbee captures. It stores each packet as a space-separated ASCII line (pkt_number timestamp channel hex_bytes...).
# Binary PCAPs are detected by the absence of "ASCII" in the file output.
echo "$FILE_INFO" | grep -qi "ASCII" && IS_DCF=1 || IS_DCF=0



# Banner

echo ""
echo -e "${C_CYAN}${BOLD}"
echo "   ███████╗██╗ ██████╗ ██████╗ ███████╗███████╗"
echo "   ╚══███╔╝██║██╔════╝ ██╔══██╗██╔════╝██╔════╝"
echo "     ███╔╝ ██║██║  ███╗██████╔╝█████╗  █████╗  "
echo "    ███╔╝  ██║██║   ██║██╔══██╗██╔══╝  ██╔══╝  "
echo "   ███████╗██║╚██████╔╝██████╔╝███████╗███████╗"
echo "   ╚══════╝╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝"
echo -e "${RESET}"
echo -e "  ${C_DARK}Zigbee Network Recon & Device Profiling • TheMalwareGuardian${RESET}"
echo ""
echo -e "  ${C_WHITE}${BOLD}Target:${RESET} ${C_YELLOW}${BOLD}$PCAP${RESET}"
echo ""



# 1. CAPTURE OVERVIEW

section "1. CAPTURE OVERVIEW"

echo -e "  ${C_DARK}$FILE_INFO${RESET}"
echo ""

# capinfos provides detailed capture metadata (packet count, duration, timestamps).
if command -v capinfos &>/dev/null; then
	capinfos "$PCAP" 2>/dev/null | grep -E "File type|File encapsulation|Number of packets|File size|Capture duration|First packet time|Last packet time" | sed 's/^/  /'
else
	echo -e "  ${C_DARK}capinfos not available.${RESET}"
fi

# wpan.channel is only present in captures with radio metadata headers.
# Tools like the TI CC2531/CC2540 USB dongle, RZUSBSTICK, or Ubertooth in 802.15.4 mode embed the channel number in a per-packet radio header.
CHANNEL=$(tshark -r "$PCAP" -T fields -e wpan.channel 2>/dev/null | grep -v '^$' | sort | uniq -c | sort -nr | head -n1 | awk '{print $2}')

echo ""
if [ -n "$CHANNEL" ]; then
	echo -e "  ${C_WHITE}${BOLD}Primary channel:${RESET} ${C_YELLOW}$CHANNEL${RESET}  ${C_DARK}(from radio metadata)${RESET}"
else
	echo -e "  ${C_DARK}Channel: not available (no radio metadata in this capture)${RESET}"
fi



# 2. PROTOCOL CLASSIFICATION

section "2. PROTOCOL CLASSIFICATION"

# Count frames at each Zigbee protocol layer.
# Each layer is decoded on top of the previous one:
#   wpan       = IEEE 802.15.4 MAC layer (always present)
#   zbee_nwk   = Zigbee Network layer (requires NWK key or unencrypted NWK)
#   zbee_aps   = Zigbee Application Support layer (above NWK)
#   zbee_zcl   = Zigbee Cluster Library (application-level commands)
#
# If wpan > 0 but zbee_nwk == 0, the NWK layer is encrypted and the key has not been loaded into tshark, or it is a non-Zigbee 802.15.4 network.
WPAN_COUNT=$(count_filter "wpan")
ZBEE_COUNT=$(count_filter "zbee_nwk")
APS_COUNT=$(count_filter "zbee_aps")
ZCL_COUNT=$(count_filter "zbee_zcl")
BEACON_COUNT=$(count_filter "wpan.frame_type == 0")

printf "  ${C_WHITE}${BOLD}%-34s${RESET} ${C_YELLOW}%s${RESET}\n" "IEEE 802.15.4 frames:"  "$WPAN_COUNT"
printf "  ${C_WHITE}${BOLD}%-36s${RESET} ${C_YELLOW}%s${RESET}\n" "  →  Beacon frames:"     "$BEACON_COUNT"
printf "  ${C_WHITE}${BOLD}%-34s${RESET} ${C_YELLOW}%s${RESET}\n" "Zigbee NWK frames:"      "$ZBEE_COUNT"
printf "  ${C_WHITE}${BOLD}%-34s${RESET} ${C_YELLOW}%s${RESET}\n" "Zigbee APS frames:"      "$APS_COUNT"
printf "  ${C_WHITE}${BOLD}%-34s${RESET} ${C_YELLOW}%s${RESET}\n" "ZCL frames:"             "$ZCL_COUNT"
echo ""

if   [ "$WPAN_COUNT" -gt 0 ] && [ "$ZBEE_COUNT" -eq 0 ]; then
	echo -e "  ${C_YELLOW}→ IEEE 802.15.4 detected but no Zigbee NWK decoded.${RESET}"
	echo -e "  ${C_DARK}  Possible: proprietary 802.15.4, or NWK key not loaded in tshark.${RESET}"
elif [ "$ZBEE_COUNT" -gt 0 ]; then
	echo -e "  ${C_GREEN}→ Zigbee traffic decoded successfully.${RESET}"
else
	echo -e "  ${C_RED}→ No Zigbee / IEEE 802.15.4 traffic found.${RESET}"
fi



# 3. PAN DISCOVERY

section "3. PAN DISCOVERY"

# The PAN ID (Personal Area Network ID) is a 16-bit identifier that scopes all communication within a Zigbee network. Multiple PANs can coexist on the same channel. The destination PAN field (wpan.dst_pan) appears in most frame types and is the most reliable field for PAN enumeration.
PAN_RESULTS=$(tshark -r "$PCAP" -T fields -e wpan.dst_pan 2>/dev/null | grep -v '^$' | sort | uniq -c | sort -nr | head -n 10)
PRIMARY_PAN=""

if [ -z "$PAN_RESULTS" ]; then
	print_empty
else
	printf "  ${C_WHITE}${BOLD}%-10s %-16s${RESET}\n" "Count" "PAN ID"
	echo -e "${C_DARK}  ----------------------------${RESET}"

	while read -r count pan; do
		printf "  ${C_GREEN}%-10s${RESET} ${C_YELLOW}%-16s${RESET}\n" "$count" "$pan"
	done <<< "$PAN_RESULTS"

	# The PAN with the most traffic is treated as the primary network
	PRIMARY_PAN=$(echo "$PAN_RESULTS" | head -n1 | awk '{print $2}')
	echo ""
	echo -e "  ${C_GREEN}Primary PAN:${RESET} ${C_YELLOW}$PRIMARY_PAN${RESET}"
fi



# 4. IEEE 802.15.4 FRAME TYPES

section "4. IEEE 802.15.4 FRAME TYPES"

# wpan.frame_type is output by tshark as a plain decimal integer (0/1/2/3).
FRAME_TYPES=$(tshark -r "$PCAP" -T fields -e wpan.frame_type 2>/dev/null | grep -v '^$' | sort | uniq -c | sort -nr)

if [ -z "$FRAME_TYPES" ]; then
	print_empty
else
	printf "  ${C_WHITE}${BOLD}%-10s %-8s %-24s${RESET}\n" "Count" "Value" "Type"
	echo -e "${C_DARK}  ------------------------------------------${RESET}"

	while read -r count raw; do
		name=$(frame_type_name "$raw")
		printf "  ${C_GREEN}%-10s${RESET} ${C_YELLOW}%-8s${RESET} ${C_WHITE}%-24s${RESET}\n" "$count" "$raw" "$name"
	done <<< "$FRAME_TYPES"
fi



# 5. ADDRESS COLLECTION

# Collect all unique 16-bit short addresses seen across four fields:
#   wpan.src16 / wpan.dst16   = MAC layer addressing
#   zbee_nwk.src / zbee_nwk.dst = NWK layer addressing (may differ from MAC)
# The regex ^0x[0-9a-fA-F]{4}$ ensures only valid 16-bit hex addresses are kept.
ALL_SHORTS=$(tshark -r "$PCAP" -T fields -e wpan.src16 -e wpan.dst16 -e zbee_nwk.src -e zbee_nwk.dst 2>/dev/null | tr '\t' '\n' | grep -E '^0x[0-9a-fA-F]{4}$' | sort -u)

# Collect all unique 64-bit extended addresses (EUI-64).
# These are the globally unique hardware identifiers, colon-separated.
ALL_LONGS=$(tshark -r "$PCAP" -T fields -e wpan.src64 -e wpan.dst64 2>/dev/null | tr '\t' '\n' | grep -E '^[0-9a-fA-F]{2}:' | sort -u)

# Filter out broadcast and reserved addresses before per-node analysis.
# These are not real devices and should not be treated as nodes:
#   0xffff = all devices (general broadcast)
#   0xfffd = all non-sleeping devices (macRxOnWhenIdle == true)
#   0xfffc = all routers + coordinator
#   0xfffb = reserved for low-power router broadcast (rarely used)
#   0xfffe = invalid / unassigned address
ROLE_DATA=$(echo "$ALL_SHORTS" | grep -vE '0xffff|0xfffd|0xfffc|0xfffb|0xfffe')



# Node Stats Cache
#
# This block runs tshark once per metric per node and stores the results in bash associative arrays. All subsequent sections read from these arrays instead of spawning new tshark processes, which would multiply execution time significantly for captures with many nodes.
#
# For a capture with 10 nodes, without caching the script would make ~50+ extra tshark calls across sections 6-12 and 22. With the cache, those calls happen exactly once here.
#
# Arrays populated:
#   NODE_SENT[$node]     = number of frames sent by this node
#   NODE_RECV[$node]     = number of frames received by this node
#   NODE_BCAST[$node]    = number of broadcast frames sent by this node
#   NODE_CLUSTERS[$node] = space-separated list of APS cluster IDs seen
#   NODE_PROFILE[$node]  = most common APS profile ID for this node

declare -A NODE_SENT NODE_RECV NODE_BCAST NODE_CLUSTERS NODE_PROFILE

if [ -n "$ROLE_DATA" ]; then
	echo -e "\n  ${C_DARK}Building node cache...${RESET}"

	for node in $ROLE_DATA; do

		# TX count, frames where this node appears as source at MAC or NWK layer
		NODE_SENT[$node]=$(tshark -r "$PCAP" -Y "wpan.src16 == $node || zbee_nwk.src == $node" 2>/dev/null | wc -l | xargs)

		# RX count, frames where this node appears as destination
		NODE_RECV[$node]=$(tshark -r "$PCAP" -Y "wpan.dst16 == $node || zbee_nwk.dst == $node" 2>/dev/null | wc -l | xargs)

		# Broadcast TX count, frames sent by this node to broadcast addresses.
		NODE_BCAST[$node]=$(tshark -r "$PCAP" -Y "(wpan.src16 == $node || zbee_nwk.src == $node) && (wpan.dst16 == 65535 || zbee_nwk.dst == 65535 || zbee_nwk.dst == 65532)" 2>/dev/null | wc -l | xargs)

		# All unique APS cluster IDs seen in traffic involving this node.
		NODE_CLUSTERS[$node]=$(tshark -r "$PCAP" -Y "zbee_nwk.src == $node || zbee_nwk.dst == $node || wpan.src16 == $node || wpan.dst16 == $node" -T fields -e zbee_aps.cluster 2>/dev/null | grep -v '^$' | sort -u | tr '\n' ' ')

		# Most frequently used APS profile for this node.
		NODE_PROFILE[$node]=$(tshark -r "$PCAP" -Y "zbee_nwk.src == $node || zbee_nwk.dst == $node" -T fields -e zbee_aps.profile 2>/dev/null | grep -v '^$' | sort | uniq -c | sort -nr | head -n1 | awk '{print $2}')
	done

	echo -e "  ${C_GREEN}✔ Cache ready (${#NODE_SENT[@]} nodes)${RESET}"
fi



# 5. ADDRESS OVERVIEW

section "5. ADDRESS OVERVIEW"

SHORT_COUNT=$(echo "$ROLE_DATA" | wc -l | xargs)
LONG_COUNT=$(echo "$ALL_LONGS" | wc -l | xargs)

printf "  ${C_WHITE}${BOLD}%-28s${RESET} ${C_YELLOW}%s${RESET}\n" "Unique 16-bit addresses:" "$SHORT_COUNT"
printf "  ${C_WHITE}${BOLD}%-28s${RESET} ${C_YELLOW}%s${RESET}\n" "Unique 64-bit addresses:" "$LONG_COUNT"

echo ""



# 6. DEVICE INVENTORY

section "6. DEVICE INVENTORY"

if [ -z "$ALL_SHORTS" ] && [ -z "$ALL_LONGS" ]; then
	print_empty
else
	printf "  ${C_WHITE}${BOLD}%-24s %-12s %-12s %-34s${RESET}\n" "Address" "Sent" "Received" "Type"
	echo -e "${C_DARK}  ----------------------------------------------------------------------------------${RESET}"

	for addr in $ALL_SHORTS; do
		# Read from cache if this address was analyzed (i.e., it's a unicast node).
		# Broadcast addresses are excluded from ROLE_DATA and thus from the cache, so they fall back to individual tshark calls here.
		sent="${NODE_SENT[$addr]:-}"
		recv="${NODE_RECV[$addr]:-}"
		if [ -z "$sent" ]; then
			sent=$(tshark -r "$PCAP" -Y "wpan.src16 == $addr || zbee_nwk.src == $addr" 2>/dev/null | wc -l | xargs)
			recv=$(tshark -r "$PCAP" -Y "wpan.dst16 == $addr || zbee_nwk.dst == $addr" 2>/dev/null | wc -l | xargs)
		fi

		case "$addr" in
			0xffff) type="Broadcast - all devices" ;;
			0xfffd) type="Broadcast - non-sleeping" ;;
			0xfffc) type="Broadcast - routers + coordinator" ;;
			0xfffb) type="Broadcast - reserved" ;;
			0xfffe) type="Invalid / unassigned" ;;
			*)      type="Unicast short address" ;;
		esac

		printf "  ${C_YELLOW}%-24s${RESET} ${C_GREEN}%-12s${RESET} ${C_GREEN}%-12s${RESET} ${C_WHITE}%-34s${RESET}\n" \
			"$addr" "$sent" "$recv" "$type"
	done

	for addr in $ALL_LONGS; do
		sent=$(tshark -r "$PCAP" -Y "wpan.src64 == $addr" 2>/dev/null | wc -l | xargs)
		recv=$(tshark -r "$PCAP" -Y "wpan.dst64 == $addr" 2>/dev/null | wc -l | xargs)
		printf "  ${C_BLUE}%-24s${RESET} ${C_GREEN}%-12s${RESET} ${C_GREEN}%-12s${RESET} ${C_WHITE}%-34s${RESET}\n" \
			"$addr" "$sent" "$recv" "Extended (EUI-64)"
	done
fi



# 7. ADDRESS CORRELATION (Short ↔ EUI-64)

section "7. ADDRESS CORRELATION"

# Some IEEE 802.15.4 frames carry both the 16-bit short address and the 64-bit extended (EUI-64) address simultaneously. This happens in:
#   - Association Request / Response frames
#   - Data frames sent with full addressing mode
# Correlating these two allows mapping hardware identifiers (EUI-64) to the ephemeral network addresses (short) assigned by the coordinator.
CORR=$(tshark -r "$PCAP" -T fields -e wpan.src16 -e wpan.src64 2>/dev/null | awk 'NF==2 && $1!="" && $2!=""' | sort -u)

if [ -z "$CORR" ]; then
	print_empty
else
	printf "  ${C_WHITE}${BOLD}%-18s %-28s${RESET}\n" "Short Address" "Extended Address (EUI-64)"
	echo -e "${C_DARK}  --------------------------------------------------${RESET}"

	while read -r short long; do
		printf "  ${C_YELLOW}%-18s${RESET} ${C_BLUE}%-28s${RESET}\n" "$short" "$long"
	done <<< "$CORR"
fi



# 8. ROLE INFERENCE

section "8. ROLE INFERENCE"

# Role classification is based on observed traffic behavior, not protocol announcements (which may be absent or unreliable in a sniffed capture):
#   Coordinator: fixed at address 0x0000 per Zigbee spec
#   Router:      high TX volume + significant broadcast activity (routers send periodic Link Status broadcasts and relay frames)
#   End Device:  very low TX - only sends its own data and polls
if [ -z "$ROLE_DATA" ]; then
	print_empty
else
	printf "  ${C_WHITE}${BOLD}%-14s %-10s %-10s %-36s${RESET}\n" "Node" "Sent" "Broadcast" "Role Guess"
	echo -e "${C_DARK}  --------------------------------------------------------------------------${RESET}"

	for node in $ROLE_DATA; do
		sent="${NODE_SENT[$node]:-0}"
		bcast="${NODE_BCAST[$node]:-0}"
		role=$(role_guess "$node" "$sent" "$bcast")
		printf "  ${C_YELLOW}%-14s${RESET} ${C_GREEN}%-10s${RESET} ${C_GREEN}%-10s${RESET} ${C_WHITE}%-36s${RESET}\n" \
			"$node" "$sent" "$bcast" "$role"
	done
fi



# 9. COMMUNICATION GRAPH

section "9. COMMUNICATION GRAPH"

# Extracts all unique src→dst pairs from the NWK layer and counts how many frames were exchanged on each edge. This builds a directed traffic graph that shows which nodes communicate and how frequently.
# The results are also exported to CSV for use in graph visualization tools like Gephi or NetworkX.
EDGES_DATA=$(tshark -r "$PCAP" -T fields -e zbee_nwk.src -e zbee_nwk.dst 2>/dev/null | awk 'NF==2 && $1!="" && $2!=""' | sort | uniq -c | sort -nr | head -n 30)

printf "count,src,dst\n" > "$EDGES_CSV"

if [ -z "$EDGES_DATA" ]; then
	print_empty
else
	printf "  ${C_WHITE}${BOLD}%-8s %-14s %-24s${RESET}\n" "Count" "Source" "Destination"
	echo -e "${C_DARK}  ------------------------------------------${RESET}"

	while read -r count src dst; do
		# Label broadcast destinations for readability
		dst_label="$dst"
		case "$dst" in
			0xffff) dst_label="0xffff (all devices)" ;;
			0xfffd) dst_label="0xfffd (non-sleeping)" ;;
			0xfffc) dst_label="0xfffc (routers)" ;;
		esac
		printf "  ${C_GREEN}%-8s${RESET} ${C_YELLOW}%-14s${RESET} ${C_WHITE}%-24s${RESET}\n" "$count" "$src" "$dst_label"
		# Write raw values (not labels) to CSV for clean machine processing
		printf "%s,%s,%s\n" "$count" "$src" "$dst" >> "$EDGES_CSV"
	done <<< "$EDGES_DATA"
fi



# 10. PROFILE / CLUSTER FINGERPRINTING

section "10. PROFILE / CLUSTER FINGERPRINTING"

# Extracts unique (profile, cluster) pairs from APS frames.
PROFILE_CLUSTER=$(tshark -r "$PCAP" -T fields -e zbee_aps.profile -e zbee_aps.cluster 2>/dev/null | awk 'NF==2 && $1!="" && $2!=""' | sort | uniq -c | sort -nr | head -n 30)

printf "count,profile,profile_name,cluster,cluster_name\n" > "$CLUSTERS_CSV"

if [ -z "$PROFILE_CLUSTER" ]; then
	print_empty
else
	printf "  ${C_WHITE}${BOLD}%-8s %-10s %-30s %-10s %-32s${RESET}\n" \
		"Count" "Profile" "Profile Name" "Cluster" "Cluster Name"
	echo -e "${C_DARK}  ---------------------------------------------------------------------------------------------${RESET}"

	while read -r count profile cluster; do
		pname=$(profile_name "$profile")
		# Dispatch cluster resolution based on profile to handle ID overlap
		cname=$(cluster_name_for_profile "$cluster" "$profile")
		printf "  ${C_GREEN}%-8s${RESET} ${C_YELLOW}%-10s${RESET} ${C_WHITE}%-30s${RESET} ${C_MAGENTA}%-10s${RESET} ${C_WHITE}%-32s${RESET}\n" \
			"$count" "$profile" "$pname" "$cluster" "$cname"
		printf "%s,%s,%s,%s,%s\n" "$count" "$profile" "$pname" "$cluster" "$cname" >> "$CLUSTERS_CSV"
	done <<< "$PROFILE_CLUSTER"
fi



# 11. ENDPOINT MAPPING

section "11. ENDPOINT MAPPING"

# APS endpoints (1-240) are logical device interfaces within a Zigbee node.
# A single physical device can host multiple endpoints, each implementing a different ZCL application (e.g., endpoint 1 = light, endpoint 2 = switch).
ENDPOINTS=$(tshark -r "$PCAP" -T fields -e zbee_aps.src_endpoint -e zbee_aps.dst_endpoint -e zbee_aps.cluster 2>/dev/null | awk 'NF==3 && $1!="" && $2!="" && $3!=""' | sort | uniq -c | sort -nr | head -n 25)

if [ -z "$ENDPOINTS" ]; then
	print_empty
else
	printf "  ${C_WHITE}${BOLD}%-8s %-10s %-10s %-12s %-30s${RESET}\n" \
		"Count" "Src EP" "Dst EP" "Cluster" "Cluster Name"
	echo -e "${C_DARK}  --------------------------------------------------------------------------${RESET}"

	while read -r count src_ep dst_ep cluster; do
		cname=$(ha_cluster_name "$cluster")
		printf "  ${C_GREEN}%-8s${RESET} ${C_WHITE}%-10s %-10s${RESET} ${C_MAGENTA}%-12s${RESET} ${C_WHITE}%-30s${RESET}\n" \
			"$count" "$src_ep" "$dst_ep" "$cluster" "$cname"
	done <<< "$ENDPOINTS"
fi



# 12. DEVICE TYPE FINGERPRINTING

section "12. DEVICE TYPE FINGERPRINTING"

# Calls device_guess() for each node using the cached stats.
# The function combines cluster IDs, profile, and traffic pattern to produce the most specific device classification possible.
if [ -z "$ROLE_DATA" ]; then
	print_empty
else
	printf "  ${C_WHITE}${BOLD}%-14s %-45s${RESET}\n" "Node" "Device Guess"
	echo -e "${C_DARK}  --------------------------------------------------------------${RESET}"

	for node in $ROLE_DATA; do
		sent="${NODE_SENT[$node]:-0}"
		recv="${NODE_RECV[$node]:-0}"
		bcast="${NODE_BCAST[$node]:-0}"
		clusters="${NODE_CLUSTERS[$node]:-}"
		profile="${NODE_PROFILE[$node]:-}"
		guess=$(device_guess "$node" "$clusters" "$profile" "$sent" "$bcast" "$recv")
		printf "  ${C_YELLOW}%-14s${RESET} ${C_WHITE}%-45s${RESET}\n" "$node" "$guess"
	done
fi



# 13. NWK COMMAND ANALYSIS

section "13. NWK COMMAND ANALYSIS"

# NWK commands are control messages at the network layer used for routing, device management, and network maintenance. They appear in frames where the NWK frame type is "Command" rather than "Data".
# Security-relevant events are flagged separately below the table:
#   - Rejoin requests: may indicate devices being kicked or network instability
#   - Leave commands: devices departing (normal or forced)
#   - High route request volume: routing instability, possible mesh flooding
NWK_CMDS=$(tshark -r "$PCAP" -T fields -e zbee_nwk.cmd.id 2>/dev/null | grep -v '^$' | sort | uniq -c | sort -nr)

if [ -z "$NWK_CMDS" ]; then
	print_empty
else
	printf "  ${C_WHITE}${BOLD}%-8s %-12s %-34s${RESET}\n" "Count" "Cmd ID" "Command"
	echo -e "${C_DARK}  -------------------------------------------------------${RESET}"

	while read -r count cmd; do
		name=$(nwk_cmd_name "$cmd")
		printf "  ${C_GREEN}%-8s${RESET} ${C_MAGENTA}%-12s${RESET} ${C_WHITE}%-34s${RESET}\n" "$count" "$cmd" "$name"
	done <<< "$NWK_CMDS"
fi

echo ""

REJOIN=$(count_filter "zbee_nwk.cmd.id == 0x06")
LEAVE=$(count_filter "zbee_nwk.cmd.id == 0x04")
ROUTE_REQ=$(count_filter "zbee_nwk.cmd.id == 0x01")

[ "$REJOIN"    -gt 0  ] && echo -e "  ${C_YELLOW}→ Rejoin requests detected ($REJOIN). Devices re-associating or potentially kicked.${RESET}"
[ "$LEAVE"     -gt 0  ] && echo -e "  ${C_YELLOW}→ Leave commands detected ($LEAVE). Device(s) left or were removed.${RESET}"
[ "$ROUTE_REQ" -gt 20 ] && echo -e "  ${C_DARK}→ High route discovery ($ROUTE_REQ requests) - network may be unstable.${RESET}"



# 14. APS COMMAND ANALYSIS

section "14. APS COMMAND ANALYSIS"

# APS commands handle security key management between devices and the Trust Center. The most critical command is Transport Key (0x05), which carries the network encryption key. If present in a cleartext APS frame, the key is exposed and the entire network can be decrypted.
APS_CMDS=$(tshark -r "$PCAP" -T fields -e zbee_aps.cmd.id 2>/dev/null | grep -v '^$' | sort | uniq -c | sort -nr)

if [ -z "$APS_CMDS" ]; then
	print_empty
else
	printf "  ${C_WHITE}${BOLD}%-8s %-12s %-34s${RESET}\n" "Count" "Cmd ID" "Command"
	echo -e "${C_DARK}  -------------------------------------------------------${RESET}"

	while read -r count cmd; do
		name=$(aps_cmd_name "$cmd")
		printf "  ${C_GREEN}%-8s${RESET} ${C_MAGENTA}%-12s${RESET} ${C_WHITE}%-34s${RESET}\n" "$count" "$cmd" "$name"
	done <<< "$APS_CMDS"
fi

echo ""

# These counts are also used in section 16 (Security Posture) and the final report
TRANSPORT_KEY=$(count_filter "zbee_aps.cmd.id == 0x05")
UPDATE_DEV=$(count_filter "zbee_aps.cmd.id == 0x06")
REMOVE_DEV=$(count_filter "zbee_aps.cmd.id == 0x07")
REQUEST_KEY=$(count_filter "zbee_aps.cmd.id == 0x08")

[ "$TRANSPORT_KEY" -gt 0 ] && echo -e "  ${C_RED}→ Transport Key detected ($TRANSPORT_KEY). Keys may be exposed if APS is unencrypted.${RESET}"
[ "$UPDATE_DEV"    -gt 0 ] && echo -e "  ${C_YELLOW}→ Update Device detected ($UPDATE_DEV). Device join/leave events.${RESET}"
[ "$REMOVE_DEV"    -gt 0 ] && echo -e "  ${C_RED}→ Remove Device detected ($REMOVE_DEV). Devices evicted from network.${RESET}"
[ "$REQUEST_KEY"   -gt 0 ] && echo -e "  ${C_YELLOW}→ Request Key detected ($REQUEST_KEY). Devices requesting keys from Trust Center.${RESET}"



# 15. ZCL COMMAND SUMMARY

section "15. ZCL COMMAND SUMMARY"

# ZCL (Zigbee Cluster Library) commands operate at the application layer.
# They are divided into:
#   - Global commands (frame_type == 0): apply to all clusters, e.g., Read/Write Attributes, Report Attributes, Configure Reporting
#   - Cluster-specific commands (frame_type == 1): defined per cluster, e.g., "Toggle" for On/Off (0x0006) or "Step" for Level Control (0x0008)
ZCL_CMDS=$(tshark -r "$PCAP" -T fields -e zbee_zcl.cmd.id -e zbee_aps.cluster 2>/dev/null | awk 'NF==2 && $1!="" && $2!=""' | sort | uniq -c | sort -nr | head -n 20)

if [ -z "$ZCL_CMDS" ]; then
	print_empty
else
	printf "  ${C_WHITE}${BOLD}%-8s %-12s %-34s %-10s %-28s${RESET}\n" \
		"Count" "ZCL Cmd" "ZCL Command Name" "Cluster" "Cluster Name"
	echo -e "${C_DARK}  ------------------------------------------------------------------------------------------${RESET}"

	while read -r count cmd cluster; do
		zname=$(zcl_cmd_name "$cmd")
		cname=$(ha_cluster_name "$cluster")
		printf "  ${C_GREEN}%-8s${RESET} ${C_MAGENTA}%-12s${RESET} ${C_WHITE}%-34s${RESET} ${C_YELLOW}%-10s${RESET} ${C_WHITE}%-28s${RESET}\n" \
			"$count" "$cmd" "$zname" "$cluster" "$cname"
	done <<< "$ZCL_CMDS"
fi



# 16. SECURITY POSTURE

section "16. SECURITY POSTURE"

# Zigbee supports encryption at three independent layers:
#   MAC (wpan.security):     IEEE 802.15.4 link-layer encryption (AES-CCM)
#   NWK (zbee_nwk.security): Zigbee network-layer encryption using the NWK key
#   APS (zbee_aps.security): Application-layer encryption using link keys
#
# A secure Zigbee network typically encrypts at NWK layer at minimum.
# APS encryption adds an additional layer for sensitive commands (key transport).
#
# NWK frames with security == 0 in a network that also has encrypted frames is a red flag - it may indicate decrypted replay, a misconfigured device, or deliberate cleartext injection.
MAC_SEC=$(count_filter "wpan.security == 1")
NWK_SEC=$(count_filter "zbee_nwk.security == 1")
APS_SEC=$(count_filter "zbee_aps.security == 1")

# Count NWK frames explicitly marked as unencrypted.
# This is only meaningful if NWK-encrypted frames also exist in the capture.
NWK_CLEAR=$(count_filter "zbee_nwk && zbee_nwk.security == 0")

printf "  ${C_WHITE}${BOLD}%-40s${RESET} ${C_YELLOW}%s frame(s)${RESET}\n" "MAC / IEEE 802.15.4 security bit:"   "$MAC_SEC"
printf "  ${C_WHITE}${BOLD}%-40s${RESET} ${C_YELLOW}%s frame(s)${RESET}\n" "Zigbee NWK security bit:"            "$NWK_SEC"
printf "  ${C_WHITE}${BOLD}%-40s${RESET} ${C_YELLOW}%s frame(s)${RESET}\n" "Zigbee APS security bit:"            "$APS_SEC"
printf "  ${C_WHITE}${BOLD}%-40s${RESET} ${C_RED}%s frame(s)${RESET}\n"    "NWK frames without security:"        "$NWK_CLEAR"
printf "  ${C_WHITE}${BOLD}%-40s${RESET} ${C_RED}%s event(s)${RESET}\n"    "Transport Key (APS cmd 0x05):"       "$TRANSPORT_KEY"

echo ""

[ "$MAC_SEC" -gt 0 ] && echo -e "  ${C_GREEN}→ MAC-layer encryption observed.${RESET}"
[ "$NWK_SEC" -gt 0 ] && echo -e "  ${C_GREEN}→ NWK-layer encryption observed.${RESET}"
[ "$APS_SEC" -gt 0 ] && echo -e "  ${C_GREEN}→ APS-layer encryption observed.${RESET}"

# Mixed NWK security, some frames encrypted, some not - always suspicious
if [ "$NWK_SEC" -gt 0 ] && [ "$NWK_CLEAR" -gt 0 ]; then
	echo -e "  ${C_RED}⚠ Mixed NWK security: encrypted and cleartext NWK frames coexist. Investigate.${RESET}"
fi

# Most critical finding: Transport Key without APS encryption means the network key is being transmitted in plaintext - full network compromise
if [ "$TRANSPORT_KEY" -gt 0 ] && [ "$APS_SEC" -eq 0 ]; then
	echo -e "  ${C_RED}⚠ CRITICAL: Transport Key frames with no APS encryption - network key likely plaintext.${RESET}"
elif [ "$TRANSPORT_KEY" -gt 0 ]; then
	echo -e "  ${C_YELLOW}→ Transport Key present. Verify APS encryption is applied to these frames.${RESET}"
fi

# No encryption at any layer with actual Zigbee traffic = unencrypted network
if [ "$MAC_SEC" -eq 0 ] && [ "$NWK_SEC" -eq 0 ] && [ "$APS_SEC" -eq 0 ] && [ "$ZBEE_COUNT" -gt 0 ]; then
	echo -e "  ${C_RED}⚠ No encryption flags at any layer - this network appears to be unencrypted.${RESET}"
fi



# 17. BEACON ANALYSIS

section "17. BEACON ANALYSIS"

# IEEE 802.15.4 beacons are transmitted by the PAN coordinator and routers to advertise network presence and synchronization information.
# In Zigbee, beacons carry an additional Zigbee-specific payload (zbee_beacon) that includes network parameters like router/device joining capacity. Beacons are used by joining devices to discover available networks. High beacon counts may indicate active scanning or network instability.
if [ "$BEACON_COUNT" -eq 0 ]; then
	print_empty
else
	echo -e "  ${C_WHITE}${BOLD}Beacon senders (PAN coordinators / routers transmitting beacons):${RESET}"
	echo ""

	BEACON_SRCS=$(tshark -r "$PCAP" -Y "wpan.frame_type == 0" -T fields -e wpan.src16 2>/dev/null | grep -v '^$' | sort | uniq -c | sort -nr)

	if [ -n "$BEACON_SRCS" ]; then
		printf "  ${C_WHITE}${BOLD}%-10s %-18s${RESET}\n" "Count" "Source"
		echo -e "${C_DARK}  ----------------------------${RESET}"
		while read -r count src; do
			printf "  ${C_GREEN}%-10s${RESET} ${C_YELLOW}%-18s${RESET}\n" "$count" "$src"
		done <<< "$BEACON_SRCS"
	fi

	echo ""

	# zbee_beacon is a sub-dissector that decodes the Zigbee superframe payload inside the 802.15.4 beacon. Not all beacons have this - raw 802.15.4 beacons without a Zigbee payload will not have this layer.
	ZBEE_BEACONS=$(count_filter "zbee_beacon")
	if [ "$ZBEE_BEACONS" -gt 0 ]; then
		echo -e "  ${C_GREEN}→ $ZBEE_BEACONS Zigbee beacon payload(s) decoded (zbee_beacon layer present).${RESET}"
		# Router/end device capacity flags indicate whether the network is currently accepting new devices - useful for joining attacks
		ROUTER_CAP=$(count_filter "zbee_beacon && zbee_beacon.router_cap == 1")
		DEV_CAP=$(count_filter "zbee_beacon && zbee_beacon.end_dev_cap == 1")
		[ "$ROUTER_CAP" -gt 0 ] && echo -e "  ${C_DARK}  Router capacity advertised in $ROUTER_CAP beacon(s).${RESET}"
		[ "$DEV_CAP"    -gt 0 ] && echo -e "  ${C_DARK}  End device capacity advertised in $DEV_CAP beacon(s).${RESET}"
	else
		echo -e "  ${C_DARK}  No Zigbee beacon payload decoded (raw 802.15.4 beacons or no Zigbee superframe).${RESET}"
	fi
fi



# 18. TOP TALKERS

section "18. TOP TALKERS"

# Ranks nodes by total NWK-layer frames sent. The most active senders are typically routers (relaying traffic) or the coordinator.
TOP_SRC=$(tshark -r "$PCAP" -T fields -e zbee_nwk.src 2>/dev/null | grep -v '^$' | sort | uniq -c | sort -nr | head -n 10)

if [ -z "$TOP_SRC" ]; then
	print_empty
else
	printf "  ${C_WHITE}${BOLD}%-8s %-14s %-30s${RESET}\n" "Count" "Node" "Role"
	echo -e "${C_DARK}  -------------------------------------------------------${RESET}"

	while read -r count node; do
		sent="${NODE_SENT[$node]:-0}"
		bcast="${NODE_BCAST[$node]:-0}"
		role=$(role_guess "$node" "$sent" "$bcast")
		printf "  ${C_GREEN}%-8s${RESET} ${C_YELLOW}%-14s${RESET} ${C_WHITE}%-30s${RESET}\n" "$count" "$node" "$role"
	done <<< "$TOP_SRC"
fi



# 19. BROADCAST / ROUTING ACTIVITY

section "19. BROADCAST / ROUTING ACTIVITY"

# Shows raw broadcast frames for manual inspection.
# Broadcast addresses used in Zigbee (decimal values for tshark filter safety):
#   65535 (0xffff) = all devices
#   65532 (0xfffc) = all routers + coordinator
# High broadcast volume typically comes from Link Status messages (routers) and route discovery (Route Request floods).
BCAST_DATA=$(tshark -r "$PCAP" -Y "zbee_nwk.dst == 65535 || zbee_nwk.dst == 65532 || wpan.dst16 == 65535" 2>/dev/null | head -n 15)

if [ -z "$BCAST_DATA" ]; then
	print_empty
else
	echo "$BCAST_DATA" | while IFS= read -r line; do
		echo "  $(clean_line "$line")"
	done
fi



# 20. DCF INSPECTION

section "20. DCF INSPECTION"

if [ "$IS_DCF" -eq 0 ]; then
	echo -e "  ${C_DARK}Standard binary PCAP - DCF inspection not applicable.${RESET}"
else
	# Daintree SNA (formerly called DCF) is a text-based 802.15.4 capture format.
	# Each packet is stored as a space-separated line:
	#   <pkt_number> <timestamp> <channel> <hex_byte> <hex_byte> ...
	# The file may also contain header/metadata lines that do not start with a number.
	echo -e "  ${C_GREEN}Daintree SNA / ASCII capture format detected.${RESET}"
	echo ""

	# Count only actual packet lines (lines starting with a digit)
	DCF_TOTAL=$(grep -cE "^[0-9]+" "$PCAP" 2>/dev/null)
	echo -e "  ${C_WHITE}${BOLD}Total packet entries:${RESET} ${C_YELLOW}$DCF_TOTAL${RESET}"

	# Extract timestamps from column 2 of packet lines
	DCF_FIRST_TS=$(grep -E "^[0-9]+" "$PCAP" 2>/dev/null | head -n1 | awk '{print $2}')
	DCF_LAST_TS=$(grep -E "^[0-9]+"  "$PCAP" 2>/dev/null | tail -n1 | awk '{print $2}')
	[ -n "$DCF_FIRST_TS" ] && echo -e "  ${C_WHITE}${BOLD}First packet:${RESET}         ${C_YELLOW}$DCF_FIRST_TS${RESET}"
	[ -n "$DCF_LAST_TS"  ] && echo -e "  ${C_WHITE}${BOLD}Last packet:${RESET}          ${C_YELLOW}$DCF_LAST_TS${RESET}"

	# Channel distribution from column 3
	# Zigbee uses channels 11-26 in the 2.4 GHz band
	echo ""
	echo -e "  ${C_WHITE}${BOLD}Channel distribution:${RESET}"
	echo -e "${C_DARK}  ----------------------------${RESET}"

	DCF_CHANNELS=$(grep -E "^[0-9]+" "$PCAP" 2>/dev/null | awk '{print $3}' | grep -E '^[0-9]+$' | sort | uniq -c | sort -nr)

	if [ -n "$DCF_CHANNELS" ]; then
		printf "  ${C_WHITE}${BOLD}%-10s %-10s${RESET}\n" "Count" "Channel"
		while read -r count ch; do
			printf "  ${C_GREEN}%-10s${RESET} ${C_YELLOW}Ch %-6s${RESET}\n" "$count" "$ch"
		done <<< "$DCF_CHANNELS"
	else
		echo -e "  ${C_DARK}  Channel column not parseable.${RESET}"
	fi

	# Payload size distribution
	# In Daintree SNA format, hex payload bytes start at column 4. Each byte is represented as a two-character hex token (e.g., "4d" "5f").
	echo ""
	echo -e "  ${C_WHITE}${BOLD}Packet size distribution (approximate):${RESET}"
	echo -e "${C_DARK}  ----------------------------${RESET}"

	grep -E "^[0-9]+" "$PCAP" 2>/dev/null | awk '{
		count = 0
		for (i = 4; i <= NF; i++) {
			if ($i ~ /^[0-9A-Fa-f]{2}$/) count++
		}
		if (count > 0) {
			if      (count <= 10)  range = "1-10 bytes"
			else if (count <= 30)  range = "11-30 bytes"
			else if (count <= 60)  range = "31-60 bytes"
			else if (count <= 100) range = "61-100 bytes"
			else                   range = ">100 bytes"
			print range
		}
	}' | sort | uniq -c | sort -rn | while read -r count range; do
		printf "  ${C_GREEN}%-10s${RESET} ${C_WHITE}%s${RESET}\n" "$count" "$range"
	done

	# Formatted packet preview - first 5 entries
	# Extracts fields individually rather than printing the raw line
	echo ""
	echo -e "  ${C_WHITE}${BOLD}Packet preview (first 5):${RESET}"
	echo -e "${C_DARK}  -----------------------------------------------------------------------${RESET}"
	printf "  ${C_WHITE}${BOLD}%-6s %-18s %-6s %-s${RESET}\n" "Pkt" "Timestamp" "Ch" "Payload (hex)"
	echo -e "${C_DARK}  -----------------------------------------------------------------------${RESET}"

	grep -E "^[0-9]+" "$PCAP" 2>/dev/null | head -n 5 | while IFS= read -r line; do
		pkt=$(echo "$line" | awk '{print $1}')
		ts=$(echo "$line"  | awk '{print $2}')
		ch=$(echo "$line"  | awk '{print $3}')
		# Extract up to 16 hex byte tokens from column 4 onward for display
		payload=$(echo "$line" | awk '{out=""; for(i=4;i<=NF&&i<=20;i++) if($i~/^[0-9A-Fa-f]{2}$/) out=out" "$i; print out}' | xargs)
		printf "  ${C_YELLOW}%-6s${RESET} ${C_DARK}%-18s${RESET} ${C_GREEN}%-6s${RESET} ${C_WHITE}%s${RESET}\n" "$pkt" "$ts" "$ch" "$payload"
	done

	# File header / metadata - lines that do NOT start with a digit
	# Daintree SNA files often include version info and capture settings here
	echo ""
	echo -e "  ${C_WHITE}${BOLD}File header / metadata:${RESET}"
	echo -e "${C_DARK}  ----------------------------${RESET}"
	grep -vE "^[0-9]+" "$PCAP" 2>/dev/null | grep -v '^$' | head -n 8 | while IFS= read -r line; do
		echo -e "  ${C_DARK}$(clean_line "$line")${RESET}"
	done
fi



# 21. WIRESHARK DISPLAY FILTERS REFERENCE

section "21. WIRESHARK DISPLAY FILTERS REFERENCE"

# A curated set of display filters for manual analysis in Wireshark.
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "wpan"                                        "All IEEE 802.15.4 frames"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "wpan.frame_type == 0"                        "Beacons only"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "wpan.frame_type == 1"                        "Data frames only"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "wpan.frame_type == 3"                        "MAC command frames"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_beacon"                                 "Zigbee beacon payloads"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_nwk"                                    "Zigbee NWK layer"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_aps"                                    "Zigbee APS layer"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_zcl"                                    "ZCL application layer"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "wpan.security == 1"                          "MAC-layer encrypted frames"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_nwk.security == 1"                      "NWK-layer encrypted frames"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_nwk && zbee_nwk.security == 0"          "NWK frames WITHOUT encryption"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_aps.security == 1"                      "APS-layer encrypted frames"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_aps.cmd.id == 0x05"                     "Transport Key - key exchange"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_aps.cmd.id == 0x06"                     "Update Device - join/leave"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_aps.cmd.id == 0x07"                     "Remove Device"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_aps.cmd.id == 0x08"                     "Request Key"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_nwk.cmd.id == 0x01"                     "Route Request"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_nwk.cmd.id == 0x04"                     "NWK Leave"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_nwk.cmd.id == 0x06"                     "NWK Rejoin Request"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_zcl.cmd.id == 0x00"                     "ZCL Read Attributes"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_zcl.cmd.id == 0x0a"                     "ZCL Report Attributes"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_nwk.dst == 65535"                       "Broadcast - all devices"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_nwk.dst == 65532"                       "Broadcast - routers + coordinator"
printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "zbee_nwk.src == 0x0000"                      "Traffic originating from coordinator"

# Dynamic filters scoped to the primary PAN discovered in section 3
if [ -n "$PRIMARY_PAN" ]; then
	printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "wpan.dst_pan == $PRIMARY_PAN"                    "Primary PAN only"
	printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "wpan.dst_pan == $PRIMARY_PAN && zbee_nwk"        "Primary PAN + NWK layer"
	printf "  ${C_WHITE}%-54s${RESET} ${C_DARK}%s${RESET}\n" "wpan.dst_pan == $PRIMARY_PAN && zbee_aps.cmd.id == 0x05"  "Key transport in primary PAN"
fi



# 22. Export CSV Inventory

section "22. EXPORTING INVENTORY"

# Writes per-node stats to CSV for offline processing, graph tools, or reporting.
# All values come from the cache - no additional tshark calls needed here.
# Three CSV files are produced:
#   devices.csv  → per-node stats: address, sent, recv, broadcast, role, device type
#   clusters.csv → profile/cluster pairs seen in APS frames (written in section 10)
#   edges.csv    → communication graph edges (written in section 9)
printf "address,sent,received,broadcast,role_guess,device_guess\n" > "$DEVICES_CSV"

for node in $ROLE_DATA; do
	sent="${NODE_SENT[$node]:-0}"
	recv="${NODE_RECV[$node]:-0}"
	bcast="${NODE_BCAST[$node]:-0}"
	clusters="${NODE_CLUSTERS[$node]:-}"
	profile="${NODE_PROFILE[$node]:-}"
	role=$(role_guess "$node" "$sent" "$bcast")
	guess=$(device_guess "$node" "$clusters" "$profile" "$sent" "$bcast" "$recv")
	printf "%s,%s,%s,%s,%s,%s\n" "$node" "$sent" "$recv" "$bcast" "$role" "$guess" >> "$DEVICES_CSV"
done

echo -e "  ${C_GREEN}[+] Devices CSV:${RESET}  $DEVICES_CSV"
echo -e "  ${C_GREEN}[+] Clusters CSV:${RESET} $CLUSTERS_CSV"
echo -e "  ${C_GREEN}[+] Edges CSV:${RESET}    $EDGES_CSV"



# 23. Final Report

section "23. FINAL RECON SUMMARY"

# Write a plain-text summary report combining all key findings.
# Variables used here were computed throughout the script:
#   WPAN_COUNT, ZBEE_COUNT, etc. - from section 2
#   MAC_SEC, NWK_SEC, etc.       - from section 16
#   TRANSPORT_KEY, REJOIN, etc.  - from sections 13-14
{
	echo "Zigbee Recon Report"
	echo "==================="
	echo ""
	echo "Target:        $PCAP"
	echo "Primary PAN:   ${PRIMARY_PAN:-N/A}"
	echo "Channel:       ${CHANNEL:-N/A (no radio metadata)}"
	echo ""
	echo "Protocol:"
	echo "  IEEE 802.15.4:  $WPAN_COUNT frames  ($BEACON_COUNT beacons)"
	echo "  Zigbee NWK:     $ZBEE_COUNT frames"
	echo "  Zigbee APS:     $APS_COUNT frames"
	echo "  ZCL:            $ZCL_COUNT frames"
	echo ""
	echo "Security:"
	echo "  MAC encrypted:        $MAC_SEC"
	echo "  NWK encrypted:        $NWK_SEC"
	echo "  NWK cleartext:        $NWK_CLEAR"
	echo "  APS encrypted:        $APS_SEC"
	echo "  Transport Key events: $TRANSPORT_KEY"
	echo "  Rejoin requests:      $REJOIN"
	echo "  Leave commands:       $LEAVE"
	echo "  Remove Device:        $REMOVE_DEV"
	echo "  Request Key:          $REQUEST_KEY"
	echo ""
	echo "Nodes analyzed: ${#NODE_SENT[@]}"
	echo ""
	echo "Output files:"
	echo "  $DEVICES_CSV"
	echo "  $CLUSTERS_CSV"
	echo "  $EDGES_CSV"
} > "$REPORT_TXT"

echo -e "  ${C_GREEN}✔ Network profiled${RESET}"
echo -e "  ${C_GREEN}✔ Devices inventoried and fingerprinted${RESET}"
echo -e "  ${C_GREEN}✔ Roles inferred${RESET}"
echo -e "  ${C_GREEN}✔ Profiles and clusters decoded (ZDP + HA)${RESET}"
echo -e "  ${C_GREEN}✔ NWK / APS / ZCL commands analyzed${RESET}"
echo -e "  ${C_GREEN}✔ Security posture evaluated${RESET}"
echo -e "  ${C_GREEN}✔ Beacons analyzed${RESET}"
echo -e "  ${C_GREEN}✔ CSV files exported${RESET}"
echo ""
echo -e "  ${C_WHITE}${BOLD}Report:${RESET} ${C_YELLOW}$REPORT_TXT${RESET}"
echo ""



# Done

echo -e "${C_CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
printf "${C_CYAN}${BOLD}║${RESET}  ${C_GREEN}${BOLD}%-52s${RESET}${C_CYAN}${BOLD}║${RESET}\n" "Zigbee recon complete."
echo -e "${C_CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
