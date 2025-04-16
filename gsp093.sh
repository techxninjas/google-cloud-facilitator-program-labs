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
BRIGHT_BLUE=`tput setaf 4; tput bold`
BRIGHT_WHITE=`tput setaf 7; tput bold`
UNDERLINE=`tput smul`

# 💡 Start-Up Banner
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}    4th Game: Level 2: Cloud Infrastructure & API Essentials    ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

# 💡 Lab Info
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}         2nd Lab: Compute Engine Qwik Start - Windows          ${RESET}" 
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

# 🚀 Task Execution Init
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}         🚀 INITIATING THE TASK EXECUTION...          ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

# Set Compute Zone
echo "${BOLD}${MAGENTA}Setting Compute Zone...${RESET}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# Step 1: Create GCP instance
echo "${BOLD}${GREEN}Creating GCP Windows instance 'instance-1'${RESET}" 
gcloud compute instances create instance-1 --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-medium --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=quicklab,image=projects/windows-cloud/global/images/windows-server-2022-dc-v20230913,mode=rw,size=50,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any 

# Step 2: Wait for instance to be ready
echo
echo "${BOLD}${CYAN}Waiting for instance setup to finish and resetting Windows password${RESET}"
INSTANCE_NAME="instance-1" 
wait_and_reset_windows_password() {
  local INSTANCE_NAME=$1
  local ZONE=$2
  local USERNAME=$3
  local SLEEP_SECONDS=30
  local RETRY=0

  echo
  echo "⏳ Waiting for instance '$INSTANCE_NAME' to finish setup..."
  echo

  while true; do
    OUTPUT=$(gcloud compute instances get-serial-port-output "$INSTANCE_NAME" --zone="$ZONE" 2>/dev/null)

    if echo "$OUTPUT" | grep -q "Instance setup finished.*ready to use"; then
      echo
      echo "✅ ${BOLD}${BLUE}Instance is ready! Resetting password for user '$USERNAME'...${RESET}"
      echo
      gcloud compute reset-windows-password "$INSTANCE_NAME" --zone="$ZONE" --user="$USERNAME" --quiet
      return
    fi

    echo
    echo "🔁 ${BOLD}${YELLOW}[Attempt $RETRY] Still waiting... Retrying in $SLEEP_SECONDS seconds.${RESET}"
    echo
    sleep $SLEEP_SECONDS
    ((RETRY++))
  done
}

wait_and_reset_windows_password instance-1 $ZONE admin 

# Task 2: RDP Progress Check
echo -e "\n${BOLD}${CYAN}Have you checked your progress for Task 2: Remote Desktop (RDP) into the Windows Server? (Y/N)${RESET}"
read task2_check

if [[ "$task2_check" != "Y" && "$task2_check" != "y" ]]; then
  echo -e "${BOLD}${RED}Please check your progress for Task 2 and enter 'Y' to proceed.${RESET}"
  exit 1
fi

# 📢 CTA
echo -e "${BRIGHT_YELLOW}${BOLD}🔔 Follow for more labs & tutorials:${RESET}"
echo -e "${BRIGHT_RED}${BOLD}YouTube Channel:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}LinkedIn Page:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.linkedin.com/company/techxninjas${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}Join WhatsApp Group:${RESET} ${BRIGHT_GREEN}${UNDERLINE}https://chat.whatsapp.com/BZczJZSamtX144BCTagYxk${RESET}"
echo ""
