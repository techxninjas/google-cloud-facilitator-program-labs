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
echo "${CYAN_TEXT}${BOLD_TEXT}------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}           Networking 101          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}------------------------------------${RESET_FORMAT}"
echo ""

# Author: Aadil Latif
# Script: TechX Ninjas Lab Setup
# Version: 1.0

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

# Enter the Main Region
echo "${YELLOW_TEXT}${BOLD_TEXT}===> Enter the Main Region (e.g., us-central1):${RESET_FORMAT}"
read -r REGION
echo "${GREEN_TEXT}${BOLD_TEXT}---> You entered: ${REGION}${RESET_FORMAT}"
echo ""

# Enter the second Region
echo "${YELLOW_TEXT}${BOLD_TEXT}===> Enter the Second Region (e.g., us-east1):${RESET_FORMAT}"
read -r REGION2
echo "${GREEN_TEXT}${BOLD_TEXT}---> You entered: ${REGION2}${RESET_FORMAT}"
echo ""

# Enter the third Region
echo "${YELLOW_TEXT}${BOLD_TEXT}===> Enter the Third Region (e.g., europe-west1):${RESET_FORMAT}"
read -r REGION3
echo "${GREEN_TEXT}${BOLD_TEXT}---> You entered: ${REGION3}${RESET_FORMAT}"
echo ""

# Set the main region and corresponding default zone
echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting the main region and default zone...${RESET_FORMAT}"
gcloud config set compute/region "$REGION"
export REGION=$(gcloud config get-value compute/region)
gcloud config set compute/zone "${REGION}-c"
export ZONE=$(gcloud config get-value compute/zone)

# Create the main network
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the main network...${RESET_FORMAT}"
gcloud compute networks create taw-custom-network --subnet-mode=custom

# Create subnets in the specified regions
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating subnets in the specified regions...${RESET_FORMAT}"
gcloud compute networks subnets create subnet-$REGION --network=taw-custom-network --region=$REGION --range=10.0.0.0/16
gcloud compute networks subnets create subnet-$REGION2 --network=taw-custom-network --region=$REGION2 --range=10.1.0.0/16
gcloud compute networks subnets create subnet-$REGION3 --network=taw-custom-network --region=$REGION3 --range=10.2.0.0/16

# Add firewall rules
echo "${BLUE_TEXT}${BOLD_TEXT}---> Adding firewall rules...${RESET_FORMAT}"
gcloud compute firewall-rules create nw101-allow-http --network=taw-custom-network --allow tcp:80 --target-tags=http --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create nw101-allow-icmp --network=taw-custom-network --allow icmp --target-tags=rules --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create nw101-allow-internal --network=taw-custom-network --allow tcp:0-65535,udp:0-65535,icmp --source-ranges=10.0.0.0/16,10.1.0.0/16,10.2.0.0/16
gcloud compute firewall-rules create nw101-allow-ssh --network=taw-custom-network --allow tcp:22 --target-tags=ssh --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create nw101-allow-rdp --network=taw-custom-network --allow tcp:3389 --source-ranges=0.0.0.0/0

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

shopt -s nullglob
for file in gsp* arc* shell*; do
    [[ -f "$file" ]] && rm "$file" && echo "Removed: $file"
done
shopt -u nullglob
echo

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
