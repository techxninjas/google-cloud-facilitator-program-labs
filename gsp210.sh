#!/bin/bash

# 🎨 Terminal Color Styling
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
NO_COLOR=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'
RESET_FORMAT=$'\033[0m'

# 🚀 Clear Screen
clear

# 🚨 Welcome Message
echo "${CYAN_TEXT}${BOLD}🚀=======================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}             6th Lab: VPC Networking Fundamentals       ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}       4th Game: Cloud Infrastructure & API Essentials         ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}======================================================🚀${RESET_FORMAT}"
echo ""

# 🌍 Prompt for Zone 2
echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Please enter the second GCP zone:${RESET_FORMAT}"
read -r ZONE_2
echo "${GREEN_TEXT}✅ 2nd Zone is: ${BOLD_TEXT}$ZONE_2${RESET_FORMAT}"

# Get default zone from project metadata
export ZONE_1=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
echo "${GREEN_TEXT}✅ 1st Zone is: ${BOLD_TEXT}$ZONE_1${RESET_FORMAT}"

# 🌐 Create VPC Network
echo "${BLUE_TEXT}${BOLD_TEXT}🔧 Creating VPC network: mynetwork...${RESET_FORMAT}"
gcloud compute networks create mynetwork \
  --project=$DEVSHELL_PROJECT_ID \
  --subnet-mode=auto \
  --mtu=1460 \
  --bgp-routing-mode=regional
echo "${GREEN_TEXT}✅ Network creation completed.${RESET_FORMAT}"

# ────────────────────────────────────────────────────────────────
# 🖥️ Create First VM (Zone 1)
# ────────────────────────────────────────────────────────────────
echo "${BLUE_TEXT}${BOLD_TEXT}🖥️ Creating first VM in zone: $ZONE_1...${RESET_FORMAT}"
gcloud compute instances create mynet-us-vm \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE_1 \
  --machine-type=e2-micro \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=mynetwork \
  --metadata=enable-oslogin=true \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --create-disk=auto-delete=yes,boot=yes,device-name=mynet-us-vm,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230509,mode=rw,size=10,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE_1/diskTypes/pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any
echo "${GREEN_TEXT}✅ First VM created successfully.${RESET_FORMAT}"

# ────────────────────────────────────────────────────────────────
# 🖥️ Create Second VM (Zone 2)
# ────────────────────────────────────────────────────────────────
echo "${BLUE_TEXT}${BOLD_TEXT}🖥️ Creating second VM in zone: $ZONE_2...${RESET_FORMAT}"
gcloud compute instances create mynet-second-vm \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE_2 \
  --machine-type=e2-micro \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=mynetwork \
  --metadata=enable-oslogin=true \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --create-disk=auto-delete=yes,boot=yes,device-name=mynet-eu-vm,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230509,mode=rw,size=10,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE_2/diskTypes/pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any
echo "${GREEN_TEXT}✅ Second VM created successfully.${RESET_FORMAT}"

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}          ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!          ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA Section
echo -e "${YELLOW_TEXT}${BOLD}🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo -e "${RED_TEXT}${BOLD}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD}Follow me on LinkedIn:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.linkedin.com/in/iaadillatif${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD}LinkedIn Page:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.linkedin.com/company/techxninjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
