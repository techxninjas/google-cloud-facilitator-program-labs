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
echo "${CYAN_TEXT}${BOLD_TEXT}           Create a Custom Network and Apply Firewall Rules         ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-----------------------------------------------------------------------${RESET_FORMAT}"
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

read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the 1st Region (Check Task 1: Step 1): ${RESET_FORMAT}" REGION1
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the 2nd Region (Check Task 1: Step 2): ${RESET_FORMAT}" REGION2
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the 3rd Region (Check Task 1: Step 3): ${RESET_FORMAT}" REGION3
echo

# Export variables after collecting input
export REGION1 REGION2 REGION3

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Authenticating and Setting Configurations...${RESET_FORMAT}"
echo

gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud config set compute/zone "$ZONE"
export ZONE=$(gcloud config get compute/zone)

gcloud config set compute/region "$REGION"
export REGION=$(gcloud config get compute/region)
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Custom Network: taw-custom-network...${RESET_FORMAT}"
echo
gcloud compute networks create taw-custom-network --subnet-mode custom
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Subnets in Different Regions...${RESET_FORMAT}"
echo

gcloud compute networks subnets create subnet-$REGION1 \
   --network taw-custom-network \
   --region $REGION1 \
   --range 10.0.0.0/16
echo
echo "${GREEN_TEXT}${BOLD_TEXT}---> Subnet subnet-$REGION1 created in $REGION1${RESET_FORMAT}"
echo

gcloud compute networks subnets create subnet-$REGION2 \
   --network taw-custom-network \
   --region $REGION2 \
   --range 10.1.0.0/16
echo
echo "${GREEN_TEXT}${BOLD_TEXT}---> Subnet subnet-$REGION2 created in $REGION2${RESET_FORMAT}"
echo

gcloud compute networks subnets create subnet-$REGION3 \
   --network taw-custom-network \
   --region $REGION3 \
   --range 10.2.0.0/16

echo
echo "${GREEN_TEXT}${BOLD_TEXT}---> Subnet subnet-$REGION3 created in $REGION3${RESET_FORMAT}"
echo

gcloud compute networks subnets list \
   --network taw-custom-network

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Firewall Rules...${RESET_FORMAT}"
echo

gcloud compute firewall-rules create nw101-allow-http \
--allow tcp:80 --network taw-custom-network --source-ranges 0.0.0.0/0 \
--target-tags http
echo
echo "${GREEN_TEXT}${BOLD_TEXT}---> Firewall Rule: nw101-allow-http created${RESET_FORMAT}"
echo

gcloud compute firewall-rules create "nw101-allow-icmp" --allow icmp --network "taw-custom-network" --target-tags rules
echo
echo "${GREEN_TEXT}${BOLD_TEXT}---> Firewall Rule: nw101-allow-icmp created${RESET_FORMAT}"
echo

gcloud compute firewall-rules create "nw101-allow-internal" --allow tcp:0-65535,udp:0-65535,icmp --network "taw-custom-network" --source-ranges "10.0.0.0/16","10.2.0.0/16","10.1.0.0/16"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}---> Firewall Rule: nw101-allow-internal created${RESET_FORMAT}"
echo

gcloud compute firewall-rules create "nw101-allow-ssh" --allow tcp:22 --network "taw-custom-network" --target-tags "ssh"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}---> Firewall Rule: nw101-allow-ssh created${RESET_FORMAT}"
echo
gcloud compute firewall-rules create "nw101-allow-rdp" --allow tcp:3389 --network "taw-custom-network"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}---> Firewall Rule: nw101-allow-rdp created${RESET_FORMAT}"
echo

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
