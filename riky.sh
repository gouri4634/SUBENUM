#!/bin/bash

# ============================================================
#                 SUBDOMAIN ENUMERATION TOOL
#                 Assetfinder + Httprobe
# ============================================================

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
PURPLE='\033[1;35m'
WHITE='\033[1;37m'
RESET='\033[0m'

# ------------------------------------------------------------
# Exit message
# ------------------------------------------------------------
exit_message() {
    echo
    echo -e "${PURPLE}========================================${RESET}"
    echo -e "${CYAN}              Bye! 👋${RESET}"
    echo -e "${PURPLE}========================================${RESET}"
    echo
}

trap exit_message EXIT

# ------------------------------------------------------------
# Clear screen
# ------------------------------------------------------------
clear

# ------------------------------------------------------------
# Big Animated Title
# ------------------------------------------------------------

echo
echo -e "${CYAN}"

sleep 0.1
echo " ███████╗██╗   ██╗██████╗ ███████╗███╗   ██╗██╗   ██╗███╗   ███╗"
sleep 0.1
echo " ██╔════╝██║   ██║██╔══██╗██╔════╝████╗  ██║██║   ██║████╗ ████║"
sleep 0.1
echo " ███████╗██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║   ██║██╔████╔██║"
sleep 0.1
echo " ╚════██║██║   ██║██╔══██╗██╔══╝  ██║╚██╗██║██║   ██║██║╚██╔╝██║"
sleep 0.1
echo " ███████║╚██████╔╝██████╔╝███████╗██║ ╚████║╚██████╔╝██║ ╚═╝ ██║"
sleep 0.1
echo " ╚══════╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝"

echo -e "${RESET}"

echo
echo -e "${PURPLE}          SUBDOMAIN ENUMERATION TOOL${RESET}"
echo -e "${BLUE}             ASSETFINDER + HTTPROBE${RESET}"
echo

# ------------------------------------------------------------
# Loading Animation
# ------------------------------------------------------------

echo -ne "${CYAN}[+] Initializing "

i=1
while [ $i -le 15 ]; do
    echo -ne "█"
    sleep 0.06
    i=$((i+1))
done

echo -e " ${GREEN}DONE${RESET}"
echo

# ------------------------------------------------------------
# Check assetfinder
# ------------------------------------------------------------

if ! command -v assetfinder >/dev/null 2>&1; then
    echo -e "${RED}[!] assetfinder is not installed.${RESET}"
    echo
    echo -e "${YELLOW}Install it using:${RESET}"
    echo "go install github.com/tomnomnom/assetfinder@latest"
    exit 1
fi

# ------------------------------------------------------------
# Check httprobe
# ------------------------------------------------------------

if ! command -v httprobe >/dev/null 2>&1; then
    echo -e "${RED}[!] httprobe is not installed.${RESET}"
    echo
    echo -e "${YELLOW}Install it using:${RESET}"
    echo "go install github.com/tomnomnom/httprobe@latest"
    exit 1
fi

# ------------------------------------------------------------
# Domain Input
# ------------------------------------------------------------

echo -e "${WHITE}----------------------------------------${RESET}"
read -p "[?] Enter domain name: " domain

# Remove http/https
domain=$(echo "$domain" | sed 's~https\?://~~')

# Remove trailing slash/path
domain=$(echo "$domain" | cut -d '/' -f1)

# Check empty domain
if [ -z "$domain" ]; then
    echo -e "${RED}[!] Domain cannot be empty.${RESET}"
    exit 1
fi

echo -e "${WHITE}----------------------------------------${RESET}"
echo
echo -e "${GREEN}[+] Target:${RESET} $domain"
echo

# ------------------------------------------------------------
# Output Files
# ------------------------------------------------------------

SUBDOMAINS="subdomains.txt"
LIVE="live_subdomains.txt"

# Remove old results
rm -f "$SUBDOMAINS" "$LIVE"

# ------------------------------------------------------------
# Assetfinder
# ------------------------------------------------------------

echo -e "${CYAN}[+] Running Assetfinder...${RESET}"
echo

assetfinder --subs-only "$domain" | sort -u > "$SUBDOMAINS"

# Check results
if [ ! -s "$SUBDOMAINS" ]; then
    echo -e "${RED}[!] No subdomains found.${RESET}"
    exit 0
fi

count=$(wc -l < "$SUBDOMAINS")

echo -e "${GREEN}[✓] Found $count unique subdomains.${RESET}"
echo

# ------------------------------------------------------------
# Display discovered subdomains
# ------------------------------------------------------------

echo -e "${BLUE}========== SUBDOMAINS ==========${RESET}"

while IFS= read -r subdomain
do
    echo -e "${WHITE}→${RESET} $subdomain"
done < "$SUBDOMAINS"

echo -e "${BLUE}=================================${RESET}"
echo

# ------------------------------------------------------------
# Loading Animation
# ------------------------------------------------------------

echo -ne "${CYAN}[+] Checking live hosts "

i=1
while [ $i -le 10 ]; do
    echo -ne "."
    sleep 0.1
    i=$((i+1))
done

echo
echo

# ------------------------------------------------------------
# Httprobe
# ------------------------------------------------------------

echo -e "${CYAN}[+] Running Httprobe...${RESET}"
echo

cat "$SUBDOMAINS" | httprobe | tee "$LIVE"

echo

# ------------------------------------------------------------
# Results
# ------------------------------------------------------------

if [ -s "$LIVE" ]; then

    live_count=$(wc -l < "$LIVE")

    echo -e "${GREEN}========================================${RESET}"
    echo -e "${GREEN}            SCAN COMPLETE${RESET}"
    echo -e "${GREEN}========================================${RESET}"
    echo
    echo -e "${CYAN}[+] Total subdomains :${RESET} $count"
    echo -e "${CYAN}[+] Live hosts       :${RESET} $live_count"
    echo
    echo -e "${YELLOW}[+] Saved files:${RESET}"
    echo -e "    → $SUBDOMAINS"
    echo -e "    → $LIVE"

else

    echo -e "${YELLOW}[!] No live HTTP/HTTPS hosts found.${RESET}"

fi

echo
echo -e "${PURPLE}========================================${RESET}"
echo -e "${CYAN}             TASK FINISHED${RESET}"
echo -e "${PURPLE}========================================${RESET}"





















