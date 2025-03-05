#!/bin/bash

# Custom Theme
BOLD="\033[1m"
CYAN="\033[1;36m"
PURPLE="\033[1;35m"
GREEN="\033[1;32m"
RED="\033[1;31m"
CRESET="\033[0m"

# Animated Banner
clear
echo -e "${PURPLE}"
cat << "EOF"
 ▄▄▄▄▄▄▄ ▄▄   ▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ 
█  ▄    █  █ █  █  ▄    █  ▄    █
█ █▄█   █  █▄█  █ █▄█   █ █▄█   █
█       █       ██      ██      ██
█  ▄   ██▄     ▄█  ▄   ██  ▄   █ 
█ █▄█   █ █   █ █ █▄█   █ █▄█   █
█▄▄▄▄▄▄▄█ █▄▄▄█ █▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█
EOF
echo -e "${CRESET}"

# Typewriter Effect
typewriter() {
    local text="$1"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep 0.03
    done
    echo
}

# Main Menu
echo -e "${CYAN}"
typewriter "[+] Select Attack Vector:"
echo -e "${PURPLE}"
typewriter "1. Localhost Server"
typewriter "2. Cloudflare Tunnel"
typewriter "3. Exit"
echo -e "${CRESET}"

# User Input
read -p "$(echo -e "${GREEN}>>> Enter Option [1-3]: ${CRESET}")" choice

# Handle Choice
case $choice in
    1)
        echo -e "\n${CYAN}[~] Starting Local Server...${CRESET}"
        read -p "$(echo -e "${GREEN}>>> Enter Port (default: 8080): ${CRESET}")" port
        port=${port:-8080}
        
        # Progress Animation
        echo -ne "${PURPLE}"
        echo -n "Initializing"
        for i in {1..5}; do
            echo -n "."
            sleep 0.3
        done
        echo -e "${CRESET}"
        
        php -S 127.0.0.1:$port > /dev/null 2>&1 &
        echo -e "\n${GREEN}[✔] Server Running: http://127.0.0.1:$port ${CRESET}"
        ;;
    2)
        echo -e "\n${CYAN}[~] Launching Cloudflare Tunnel...${CRESET}"
        echo -ne "${PURPLE}Establishing Connection"
        for i in {1..3}; do
            echo -n "."
            sleep 0.5
        done
        echo -e "${CRESET}"
        
        cloudflared tunnel --url http://localhost:8080 | grep -o 'https://[^ ]*' | head -1
        ;;
    3)
        echo -e "\n${RED}[!] Exiting...${CRESET}"
        exit 0
        ;;
    *)
        echo -e "${RED}[X] Invalid Option!${CRESET}"
        exit 1
        ;;
esac

# Session Monitor
echo -e "\n${CYAN}[~] Active Session Monitoring Started..."
echo -e "${GREEN}[!] Press Ctrl+C to Stop${CRESET}"
tail -f log.txt
