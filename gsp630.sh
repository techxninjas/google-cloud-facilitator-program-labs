#!/bin/bash

BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# 💡 Start-Up Banner
echo "${CYAN_TEXT}${BOLD_TEXT}-----------------------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}           Getting Started with API Gateway: Challenge Lab             ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-----------------------------------------------------------------------${RESET_FORMAT}"
echo ""

# 🌍 Fetching Region
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔄 Fetching Region...${RESET_FORMAT}"
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")
echo ""

# 🗺️ Fetching Zone
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔄 Fetching Zone...${RESET_FORMAT}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")
echo ""

# 🆔 Fetching Project ID
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔍 Fetching Project ID...${RESET_FORMAT}"
PROJECT_ID=`gcloud config get-value project`
echo ""

# 🔢 Fetching Project Number
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔍 Fetching Project Number...${RESET_FORMAT}"
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
echo ""
echo ""

# 💡 Start-Up Banner
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         🚀 INITIATING THE TASK EXECUTION...          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo ""

echo "${CYAN_TEXT}${BOLD_TEXT}Creating a custom-mode VPC network named 'labnet'...${RESET_FORMAT}"
gcloud compute networks create labnet --subnet-mode=custom

echo "${CYAN_TEXT}${BOLD_TEXT}Creating a subnet 'labnet-sub' within the 'labnet' network in region ${WHITE_TEXT}$REGION${CYAN_TEXT}${BOLD_TEXT} with IP range 10.0.0.0/28...${RESET_FORMAT}"
gcloud compute networks subnets create labnet-sub \
   --network labnet \
   --region "$REGION" \
   --range 10.0.0.0/28
echo

echo "${CYAN_TEXT}${BOLD_TEXT}Listing all VPC networks in the project...${RESET_FORMAT}"
gcloud compute networks list

echo "${CYAN_TEXT}${BOLD_TEXT}Setting up firewall rule 'labnet-allow-internal' for 'labnet' to permit ICMP and TCP port 22 (SSH) from all sources (0.0.0.0/0)...${RESET_FORMAT}"
gcloud compute firewall-rules create labnet-allow-internal \
    --network=labnet \
    --action=ALLOW \
    --rules=icmp,tcp:22 \
    --source-ranges=0.0.0.0/0
echo

echo "${CYAN_TEXT}${BOLD_TEXT}Creating another custom-mode VPC network named 'privatenet'...${RESET_FORMAT}"
gcloud compute networks create privatenet --subnet-mode=custom
echo

echo "${CYAN_TEXT}${BOLD_TEXT}Creating a subnet 'private-sub' within the 'privatenet' network in region ${WHITE_TEXT}$REGION${CYAN_TEXT}${BOLD_TEXT} with IP range 10.1.0.0/28...${RESET_FORMAT}"
gcloud compute networks subnets create private-sub \
    --network=privatenet \
    --region="$REGION" \
    --range 10.1.0.0/28
echo

echo "${CYAN_TEXT}${BOLD_TEXT}Setting up firewall rule 'privatenet-deny' for 'privatenet' to block ICMP and TCP port 22 (SSH) from all sources (0.0.0.0/0)...${RESET_FORMAT}"
gcloud compute firewall-rules create privatenet-deny \
    --network=privatenet \
    --action=DENY \
    --rules=icmp,tcp:22 \
    --source-ranges=0.0.0.0/0
echo

echo "${CYAN_TEXT}${BOLD_TEXT}Listing all firewall rules, sorted by network, to review our configurations...${RESET_FORMAT}"
gcloud compute firewall-rules list --sort-by=NETWORK
echo

echo "${CYAN_TEXT}${BOLD_TEXT}Launching a new VM instance named 'pnet-vm' in zone ${WHITE_TEXT}$ZONE${CYAN_TEXT}${BOLD_TEXT}, connected to the 'private-sub' subnet...${RESET_FORMAT}"
gcloud compute instances create pnet-vm \
--zone="$ZONE" \
--machine-type=n1-standard-1 \
--subnet=private-sub
echo

echo "${CYAN_TEXT}${BOLD_TEXT}Launching another new VM instance named 'lnet-vm' in zone ${WHITE_TEXT}$ZONE${CYAN_TEXT}${BOLD_TEXT}, connected to the 'labnet-sub' subnet...${RESET_FORMAT}"
gcloud compute instances create lnet-vm \
--zone="$ZONE" \
--machine-type=n1-standard-1 \
--subnet=labnet-sub
echo ""

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}               ✅ ALL TASKS COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your progress."
echo "${GREEN_TEXT}${BOLD_TEXT} If it will be not completed, try again for successfully completion of the Assessment."
echo ""

for i in {1..20}; do
    echo -ne "${CYAN_TEXT}⏳ ${i}/20 seconds to check your progress\r${RESET_FORMAT}"
    sleep 1
done
echo ""

remove_temp_files() {
    echo "${YELLOW_TEXT}${BOLD_TEXT}Cleaning up temporary files...${RESET_FORMAT}"
    for file in *; do
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            [[ -f "$file" ]] && rm "$file" && echo "Removed: $file"
        fi
    done
}
remove_temp_files
echo ""

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}          ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!          ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA Section
echo -e "${YELLOW_TEXT}${BOLD_TEXT}🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo ""
echo -e "${WHITE_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@techxninjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
