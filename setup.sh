#!/bin/bash

# Custom Color Scheme
DANGER='\033[0;31m'     # Red
SUCCESS='\033[0;32m'    # Green
WARNING='\033[0;33m'    # Yellow
PRIMARY='\033[0;34m'     # Blue
INFO='\033[0;36m'       # Cyan
PURPLE='\033[0;35m'     # Purple
MAGENTA='\033[1;35m'    # Magenta
BOLD='\033[1m'          # Bold
RESET='\033[0m'         # Reset

# Detect OS with color
detect_os() {
    if [ -d "$PREFIX" ] && [ -x "$(command -v pkg)" ]; then
        echo -e "${SUCCESS}✓${RESET} ${BOLD}Termux Detected!${RESET}"
        echo "termux"
    elif grep -q 'Kali' /etc/os-release 2>/dev/null; then
        echo -e "${PRIMARY}🐧${RESET} ${BOLD}Kali Linux Detected!${RESET}"
        echo "kali"
    else
        echo -e "${DANGER}⚠${RESET} ${BOLD}Unknown OS!${RESET}"
        echo "unknown"
    fi
}

# Installation functions with color
install_termux() {
    echo -e "\n${PRIMARY}»»${RESET} ${BOLD}Starting Termux Installation...${RESET}"
    
    # PHP Installation
    if ! command -v php &> /dev/null; then
        echo -e "${WARNING}➤${RESET} Installing PHP..."
        pkg install php -y 2>&1 | while read -r line; do 
            echo -e "${INFO}${BOLD}[PHP]${RESET} ${line}"
        done
        echo -e "${SUCCESS}✓ PHP Installed!${RESET}"
    else
        echo -e "${INFO}ℹ PHP Already Installed!${RESET}"
    fi

    # Cloudflared Installation
    if ! command -v cloudflared &> /dev/null; then
        echo -e "\n${WARNING}➤${RESET} Installing Cloudflared...(It may takes 2-6 minute)"
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O $PREFIX/bin/cloudflared
        chmod +x $PREFIX/bin/cloudflared
        echo -e "${SUCCESS}✓ Cloudflared Installed!${RESET}"
    else
        echo -e "${INFO}ℹ Cloudflared Already Installed!${RESET}"
    fi
}

install_kali() {
    echo -e "\n${PRIMARY}»»${RESET} ${BOLD}Starting Kali Linux Installation...${RESET}"
    
    # PHP Installation
    if ! command -v php &> /dev/null; then
        echo -e "${WARNING}➤${RESET} Installing PHP..."
        sudo apt install php -y 2>&1 | while read -r line; do
            echo -e "${INFO}${BOLD}[PHP]${RESET} ${line}"
        done
        echo -e "${SUCCESS}✓ PHP Installed!${RESET}"
    else
        echo -e "${INFO}ℹ PHP Already Installed!${RESET}"
    fi

    # Cloudflared Installation
    if ! command -v cloudflared &> /dev/null; then
        echo -e "\n${WARNING}➤${RESET} Installing Cloudflared..."
        sudo apt install cloudflared -y 2>&1 | while read -r line; do
            echo -e "${INFO}${BOLD}[CLOUDFLARED]${RESET} ${line}"
        done
        echo -e "${SUCCESS}✓ Cloudflared Installed!${RESET}"
    else
        echo -e "${INFO}ℹ Cloudflared Already Installed!${RESET}"
    fi
}

# Main menu
clear
echo -e "${PURPLE}${BOLD}"
cat << "EOF"
 ____    _    ____ ___ ____  
/ ___|  / \  | __ )_ _|  _ \ 
\___ \ / _ \ |  _ \| || |_) |
 ___) / ___ \| |_) | ||  _ < 
|____/_/   \_\____/___|_| \_\ 
EOF
echo -e "${RESET}"

echo -e "${BOLD}${INFO}Choose Installation Type:${RESET}"
echo -e "  ${SUCCESS}[1]${RESET} ${BOLD}Auto Detect (Recommended)${RESET}"
echo -e "  ${WARNING}[2]${RESET} ${BOLD}Termux Installation${RESET}"
echo -e "  ${PRIMARY}[3]${RESET} ${BOLD}Kali Linux Installation${RESET}"
echo -e "  ${DANGER}[4]${RESET} ${BOLD}Exit Installer${RESET}"

read -p "$(echo -e "${MAGENTA}${BOLD}➤ Enter your choice [1-4]: ${RESET}")" choice

case $choice in
    1)
        os=$(detect_os | tail -1)
        if [ "$os" == "termux" ]; then
            install_termux
        elif [ "$os" == "kali" ]; then
            install_kali
        else
            echo -e "\n${DANGER}${BOLD}✖ Error: Unsupported OS!${RESET}"
            echo -e "${WARNING}Please manually install dependencies:"
            echo -e "- PHP (php.net)"
            echo -e "- Cloudflared (cloudflare.com)${RESET}"
            exit 1
        fi
        ;;
    2)
        if grep -q 'Kali' /etc/os-release 2>/dev/null; then
            echo -e "\n${DANGER}${BOLD}✖ Error: You selected Termux but running Kali!${RESET}"
            exit 1
        fi
        install_termux
        ;;
    3)
        if [ -d "$PREFIX" ]; then
            echo -e "\n${DANGER}${BOLD}✖ Error: You selected Kali but running Termux!${RESET}"
            exit 1
        fi
        install_kali
        ;;
    4)
        echo -e "\n${MAGENTA}${BOLD}❤ Thank you! Exiting...${RESET}"
        exit 0
        ;;
    *)
        echo -e "\n${DANGER}${BOLD}✖ Invalid choice!${RESET}"
        exit 1
        ;;
esac

# Post-install message
echo -e "\n${SUCCESS}${BOLD}✔ Installation Completed Successfully!${RESET}"
echo -e "${PRIMARY}${BOLD}➤ Run the phishing tool with:"
echo -e "${INFO}bash run.sh${RESET}\n"
