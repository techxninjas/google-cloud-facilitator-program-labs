clear

#!/bin/bash
# Define color variables

BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

# Additional Styling
BRIGHT_PURPLE=`tput setaf 5; tput bold`
BRIGHT_CYAN=`tput setaf 6; tput bold`
BRIGHT_YELLOW=`tput setaf 3; tput bold`
BRIGHT_RED=`tput setaf 1; tput bold`
BRIGHT_GREEN=`tput setaf 2; tput bold`
BRIGHT_BLUE=`tput setaf 4; tput bold`
BRIGHT_WHITE=`tput setaf 7; tput bold`
UNDERLINE=`tput smul`

# 💡 Start-Up Banner
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}       4th Game: Level 1: Deploy & Configure VMs       ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

# 💡 Lab Info
echo -e "${BRIGHT_PURPLE}${BOLD}---------------------------------------------------------------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}                 4th Lab: Deploy a Compute Instance with a Remote Startup Script: Challenge Lab                 ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}---------------------------------------------------------------------------------------------------------------${RESET}"
echo ""

# 🚀 Task Execution Init
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}         🚀 INITIATING THE TASK EXECUTION...           ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

# Zone Input
read -p "$(echo -e ${BRIGHT_MAGENTA}${BOLD}Enter the compute zone: ${RESET})" ZONE
export ZONE

# Step 1: Create a bucket
echo -e "\n${BOLD}${GREEN}Task 1: Creating a storage bucket in your project...${RESET}"
echo -e "${BOLD}${CYAN}This bucket will store the startup script.${RESET}"
gsutil mb gs://$DEVSHELL_PROJECT_ID

# ✅ Task 1 Checkpoint
while true; do
    read -p "$(echo -e ${YELLOW}${BOLD}Have you checked your progress for Task 1? (Y/N): ${RESET})" confirm
    case $confirm in
        [Yy]* ) break;;
        * ) echo -e "${RED}⚠️ Please check your progress and type Y to continue.${RESET}";;
    esac
done

# Step 2: Copy startup script
echo -e "\n${BOLD}${GREEN}Task 2: Copying the startup script to the bucket...${RESET}"
echo -e "${BOLD}${CYAN}The script will be used to configure the VM instance.${RESET}"
gsutil cp gs://sureskills-ql/challenge-labs/ch01-startup-script/install-web.sh gs://$DEVSHELL_PROJECT_ID

# Step 3: Create Compute Engine instance
echo -e "\n${BOLD}${GREEN}Creating a Compute Engine instance...${RESET}"
echo -e "${BOLD}${CYAN}This instance will run the startup script to set up a web server.${RESET}"
gcloud compute instances create instance-15f6f \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE \
    --machine-type=n1-standard-1 \
    --tags=http-server \
    --metadata startup-script-url=gs://$DEVSHELL_PROJECT_ID/install-web.sh

# ✅ Task 2 Checkpoint
while true; do
    read -p "$(echo -e ${YELLOW}${BOLD}Have you checked your progress for Task 2? (Y/N): ${RESET})" confirm
    case $confirm in
        [Yy]* ) break;;
        * ) echo -e "${RED}⚠️ Please check your progress and type Y to continue.${RESET}";;
    esac
done

# Step 4: Create firewall rule
echo -e "\n${BOLD}${GREEN}Task 3: Setting up firewall rule to allow HTTP traffic...${RESET}"
echo -e "${BOLD}${CYAN}This will enable access to the web server on port 80.${RESET}"
gcloud compute firewall-rules create allow-http \
    --allow=tcp:80 \
    --description="awesome lab" \
    --direction=INGRESS \
    --target-tags=http-server

# ✅ Task 3 Checkpoint
while true; do
    read -p "$(echo -e ${YELLOW}${BOLD}Have you checked your progress for Task 3? (Y/N): ${RESET})" confirm
    case $confirm in
        [Yy]* ) break;;
        * ) echo -e "${RED}⚠️ Please check your progress and type Y to continue.${RESET}";;
    esac
done

# Step 5: Testing the server
echo -e "\n${BOLD}${GREEN}Task 4: Test that the VM is serving web content...${RESET}"
echo -e "${BOLD}${CYAN}Visit your external IP address in the browser.${RESET}"

# ✅ Task 4 Checkpoint
while true; do
    read -p "$(echo -e ${YELLOW}${BOLD}Have you checked your progress for Task 4? (Y/N): ${RESET})" confirm
    case $confirm in
        [Yy]* ) break;;
        * ) echo -e "${RED}⚠️ Please check your progress and type Y to continue.${RESET}";;
    esac
done

# 🎉 Completion Message
echo ""
echo "${BRIGHT_GREEN}${BOLD}🎉===========================================================${RESET}"
echo "${BRIGHT_GREEN}${BOLD}            ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!         ${RESET}"
echo "${BRIGHT_GREEN}${BOLD}🎉===========================================================${RESET}"
echo ""

# 📢 CTA
echo -e "${BRIGHT_YELLOW}${BOLD}🔔 Follow for more labs & tutorials:${RESET}"
echo -e "${BRIGHT_RED}${BOLD}YouTube Channel:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}Follow me on LinkedIn:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.linkedin.com/in/iaadillatif${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}LinkedIn Page:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.linkedin.com/company/techxninjas${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}Join WhatsApp Group:${RESET} ${BRIGHT_GREEN}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET}"
echo ""
