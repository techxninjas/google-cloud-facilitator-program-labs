#!/bin/bash

# 🎨 Stylish Color Variables
RESET_FORMAT=$'\033[0m'

# Text colors
GRAY=$'\033[0;90m'
BRIGHT_RED=$'\033[1;91m'
BRIGHT_GREEN=$'\033[1;92m'
BRIGHT_YELLOW=$'\033[1;93m'
BRIGHT_BLUE=$'\033[1;94m'
BRIGHT_PURPLE=$'\033[1;95m'
BRIGHT_CYAN=$'\033[1;96m'
BRIGHT_WHITE=$'\033[1;97m'

# Text styles
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'

clear

# 💡 Start-Up Banner
echo "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo "${BRIGHT_CYAN}${BOLD}    4th Game: Level 2: Cloud Infrastructure & API Essentials    ${RESET_FORMAT}"
echo "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo ""

# 💡 Start-Up Banner
echo "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo "${BRIGHT_CYAN}${BOLD}         1st Lab: APIs Explorer: Compute Engine          ${RESET_FORMAT}"
echo "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo ""

# 💡 Start-Up Banner
echo "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo "${BRIGHT_CYAN}${BOLD}         🚀 INITIATING THE TASK EXECUTION...          ${RESET_FORMAT}"
echo "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo ""

# 🌍 Fetching Region
echo "${BRIGHT_GREEN}${BOLD}🔄 Fetching Region...${RESET_FORMAT}"
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

# 🗺️ Fetching Zone
echo "${BRIGHT_GREEN}${BOLD}🔄 Fetching Zone...${RESET_FORMAT}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# 🆔 Fetching Project ID
echo "${BRIGHT_GREEN}${BOLD}🔍 Fetching Project ID...${RESET_FORMAT}"
PROJECT_ID=`gcloud config get-value project`

# 🔢 Fetching Project Number
echo "${BRIGHT_GREEN}${BOLD}🔍 Fetching Project Number...${RESET_FORMAT}"
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

# 🖥️ Instance Creation Prompt
echo "${BRIGHT_BLUE}${BOLD}🚧 Creating Compute Engine Instance: 'instance-1'...${RESET_FORMAT}"
echo "${BRIGHT_YELLOW}${BOLD}🔧 Configuration Summary:${RESET_FORMAT}"
echo "${BRIGHT_WHITE}- Machine type: ${BOLD}n1-standard-1${RESET_FORMAT}"
echo "${BRIGHT_WHITE}- Image family: ${BOLD}debian-11${RESET_FORMAT}"
echo "${BRIGHT_WHITE}- Disk type: ${BOLD}pd-standard${RESET_FORMAT}"
echo ""

# 🔨 Create the VM
gcloud compute instances create instance-1 \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --machine-type=n1-standard-1 \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --boot-disk-type=pd-standard \
  --boot-disk-device-name=instance-1
echo ""

# ✅ Progress Check Prompt for Task 2
echo ""
while true; do
  echo "${BRIGHT_CYAN}${BOLD}📌 Have you checked the progress for ${UNDERLINE}Task 2: Create your request${RESET_FORMAT}${BRIGHT_CYAN}${BOLD}? (Y/N)${RESET_FORMAT}"
  read -p "👉 Enter Y after checking the Task 2 progress: " TASK2_CONFIRM
  if [[ "$TASK2_CONFIRM" == "Y" || "$TASK2_CONFIRM" == "y" ]]; then
    echo ""
    break
  else
    echo ""
    echo "${BRIGHT_RED}${BOLD}⚠️  Please check your progress first and then enter 'Y' to continue.${RESET_FORMAT}"
  fi
done
echo ""

# 🧹 Delete the VM
echo "${BRIGHT_RED}${BOLD}Deleting VM: 'instance-1'...${RESET_FORMAT}"
echo "${BRIGHT_YELLOW}${BOLD}Cleaning up your environment to avoid extra charges.${RESET_FORMAT}"
echo ""

gcloud compute instances delete instance-1 \
  --project=$PROJECT_ID \
  --zone=$ZONE --quiet

# ✅ Progress Check Prompt for Task 5
echo ""
while true; do
  echo "${BRIGHT_CYAN}${BOLD}📌 Have you checked the progress for ${UNDERLINE}Task 5: Delete your VM${RESET_FORMAT}${BRIGHT_CYAN}${BOLD}? (Y/N)${RESET_FORMAT}"
  read -p "👉 Enter Y after checking the Task 5 progress: " TASK5_CONFIRM
  if [[ "$TASK5_CONFIRM" == "Y" || "$TASK5_CONFIRM" == "y" ]]; then
    echo ""
    break
  else
    echo ""
    echo "${BRIGHT_RED}${BOLD}⚠️  Please check your progress first and then enter 'Y' to continue.${RESET_FORMAT}"
  fi
done
echo ""

# ✅ Completion Message
echo "${BRIGHT_GREEN}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${BRIGHT_GREEN}${BOLD}             ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!         ${RESET_FORMAT}"
echo "${BRIGHT_GREEN}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""


# 📢 CTA
echo -e "${BRIGHT_YELLOW}${BOLD}🔔 Follow for more labs & tutorials:${RESET}"
echo -e "${BRIGHT_RED}${BOLD}YouTube Channel:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}Follow me on LinkedIn:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.linkedin.com/in/iaadillatif${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}LinkedIn Page:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.linkedin.com/company/techxninjas${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}Join WhatsApp Group:${RESET} ${BRIGHT_GREEN}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET}"
echo ""
