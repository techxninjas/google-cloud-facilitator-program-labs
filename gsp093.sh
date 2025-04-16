#!/bin/bash
clear

# 🎨 Unified ANSI Color Codes
RESET_FORMAT="\e[0m"
BOLD="\e[1m"
UNDERLINE="\e[4m"

BRIGHT_GREEN="\e[92m"
BRIGHT_RED="\e[91m"
BRIGHT_YELLOW="\e[93m"
BRIGHT_BLUE="\e[94m"
BRIGHT_WHITE="\e[97m"
BRIGHT_CYAN="\e[96m"
BRIGHT_PURPLE="\e[95m"

TEXT_COLORS=($BRIGHT_RED $BRIGHT_GREEN $BRIGHT_YELLOW $BRIGHT_BLUE $BRIGHT_PURPLE $BRIGHT_CYAN)
BG_COLORS=(41 42 43 44 45 46)

RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_CODE=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

echo -e "\e[${RANDOM_BG_CODE}m${RANDOM_TEXT_COLOR}${BOLD}Starting Execution...${RESET_FORMAT}"

# 💡 Start-Up Banner
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo -e "${BRIGHT_CYAN}${BOLD}    4th Game: Level 2: Cloud Infrastructure & API Essentials    ${RESET_FORMAT}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo ""

# 💡 Lab Info
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo -e "${BRIGHT_CYAN}${BOLD}         2nd Lab: Compute Engine Qwik Start - Windows          ${RESET_FORMAT}" 
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo ""

# 🚀 Task Execution Init
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo -e "${BRIGHT_CYAN}${BOLD}         🚀 INITIATING THE TASK EXECUTION...          ${RESET_FORMAT}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo ""

# ✅ Task List
echo -e "${BRIGHT_YELLOW}${BOLD}📌 Tasks to Complete:${RESET_FORMAT}"
echo -e "${BRIGHT_WHITE}${BOLD}1.${RESET_FORMAT} Create a virtual machine instance"
echo -e "${BRIGHT_WHITE}${BOLD}2.${RESET_FORMAT} Remote Desktop (RDP) into the Windows Server"
echo -e "${BRIGHT_WHITE}${BOLD}3.${RESET_FORMAT} Set up and explore the VM environment"
echo -e "${BRIGHT_WHITE}${BOLD}4.${RESET_FORMAT} Configure firewall rules"
echo -e "${BRIGHT_WHITE}${BOLD}5.${RESET_FORMAT} Connect and verify the server setup"
echo ""

# 🔎 Task 2 Input Check
read -p "$(echo -e ${BRIGHT_CYAN}${BOLD}Have you checked your progress for Task 2 (RDP into the Windows Server)? Enter Y to continue: ${RESET_FORMAT})" task2_input
while [[ "$task2_input" != "Y" && "$task2_input" != "y" ]]; do
    echo -e "${BRIGHT_RED}${BOLD}⚠️  Please check your progress and enter Y to go ahead.${RESET_FORMAT}"
    read -p "$(echo -e ${BRIGHT_CYAN}${BOLD}Have you checked your progress for Task 2? Enter Y to continue: ${RESET_FORMAT})" task2_input
done
echo ""

# 🔎 Task 5 Input Check
read -p "$(echo -e ${BRIGHT_CYAN}${BOLD}Have you checked your progress for Task 5 (Connect and verify the server setup)? Enter Y to continue: ${RESET_FORMAT})" task5_input
while [[ "$task5_input" != "Y" && "$task5_input" != "y" ]]; do
    echo -e "${BRIGHT_RED}${BOLD}⚠️  Please check your progress and enter Y to go ahead.${RESET_FORMAT}"
    read -p "$(echo -e ${BRIGHT_CYAN}${BOLD}Have you checked your progress for Task 5? Enter Y to continue: ${RESET_FORMAT})" task5_input
done
echo ""

# ⚙️ GCP Setup and VM Creation
echo -e "${BRIGHT_PURPLE}${BOLD}Setting Compute Zone...${RESET_FORMAT}"
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

echo -e "${BRIGHT_GREEN}${BOLD}Creating GCP Windows instance 'quickgcplab'${RESET_FORMAT}"
gcloud compute instances create quickgcplab \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --machine-type=e2-medium \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=enable-oslogin=true \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
  --create-disk=auto-delete=yes,boot=yes,device-name=quicklab,image=projects/windows-cloud/global/images/windows-server-2022-dc-v20230913,mode=rw,size=50,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any

# ⏳ Wait for VM Setup and Reset Password
echo -e "${BRIGHT_CYAN}${BOLD}Waiting for instance setup to finish and resetting Windows password...${RESET_FORMAT}"
wait_and_reset_windows_password() {
  local INSTANCE_NAME=$1
  local ZONE=$2
  local USERNAME=$3
  local SLEEP_SECONDS=30
  local RETRY=0

  echo -e "\n⏳ Waiting for instance '$INSTANCE_NAME' to finish setup...\n"

  while true; do
    OUTPUT=$(gcloud compute instances get-serial-port-output "$INSTANCE_NAME" --zone="$ZONE" 2>/dev/null)

    if echo "$OUTPUT" | grep -q "Instance setup finished.*ready to use"; then
      echo -e "\n✅ ${BRIGHT_BLUE}${BOLD}Instance is ready! Resetting password for user '$USERNAME'...${RESET_FORMAT}\n"
      gcloud compute reset-windows-password "$INSTANCE_NAME" --zone="$ZONE" --user="$USERNAME" --quiet
      return
    fi

    echo -e "🔁 ${BRIGHT_YELLOW}${BOLD}[Attempt $RETRY] Still waiting... Retrying in $SLEEP_SECONDS seconds.${RESET_FORMAT}"
    sleep $SLEEP_SECONDS
    ((RETRY++))
  done
}
wait_and_reset_windows_password quickgcplab $ZONE admin

# 🎉 Random Congratulatory Message
function random_congrats() {
    MESSAGES=(
        "${BRIGHT_GREEN}Congratulations For Completing The Lab! Keep up the great work!${RESET_FORMAT}"
        "${BRIGHT_CYAN}Well done! Your hard work and effort have paid off!${RESET_FORMAT}"
        "${BRIGHT_YELLOW}Amazing job! You’ve successfully completed the lab!${RESET_FORMAT}"
        "${BRIGHT_BLUE}Outstanding! Your dedication has brought you success!${RESET_FORMAT}"
        "${BRIGHT_PURPLE}Great work! You’re one step closer to mastering this!${RESET_FORMAT}"
        "${BRIGHT_RED}Fantastic effort! You’ve earned this achievement!${RESET_FORMAT}"
    )

    RANDOM_INDEX=$((RANDOM % ${#MESSAGES[@]}))
    echo -e "\n${BOLD}${MESSAGES[$RANDOM_INDEX]}\n"
}
random_congrats

# 🧹 Clean Up Files
cd ~
remove_files() {
    for file in *; do
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            if [[ -f "$file" ]]; then
                rm "$file"
                echo -e "🗑️  File removed: $file"
            fi
        fi
    done
}
remove_files

# ✅ Finished
echo -e "${BRIGHT_GREEN}${BOLD}✅ Script execution completed!${RESET_FORMAT}\n"

# 📢 CTA
echo -e "${BRIGHT_YELLOW}${BOLD}🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo -e "${BRIGHT_RED}${BOLD}YouTube Channel:${RESET_FORMAT} ${BRIGHT_BLUE}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET_FORMAT}"
echo -e "${BRIGHT_WHITE}${BOLD}LinkedIn Page:${RESET_FORMAT} ${BRIGHT_BLUE}${UNDERLINE}https://www.linkedin.com/company/techxninjas${RESET_FORMAT}"
echo -e "${BRIGHT_WHITE}${BOLD}Join WhatsApp Group:${RESET_FORMAT} ${BRIGHT_GREEN}${UNDERLINE}https://chat.whatsapp.com/BZczJZSamtX144BCTagYxk${RESET_FORMAT}"
echo ""
