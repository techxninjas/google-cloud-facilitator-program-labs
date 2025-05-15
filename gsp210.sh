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
echo "${CYAN_TEXT}${BOLD}                     VPC Networking Fundamentals       ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}======================================================🚀${RESET_FORMAT}"
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

# 🌍 Prompt for Zone 2
echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Please enter the second GCP zone:${RESET_FORMAT}"
read -r ZONE_2
echo "${GREEN_TEXT}✅ 2nd Zone is: ${BOLD_TEXT}$ZONE_2${RESET_FORMAT}"

# Get default zone from project metadata
export ZONE_1=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
echo "${GREEN_TEXT}✅ 1st Zone is: ${BOLD_TEXT}$ZONE_1${RESET_FORMAT}"

# Delete the default VPC network
echo "Deleting default VPC network..."
gcloud compute networks delete default --quiet

# 🌐 Create VPC Network
echo "${BLUE_TEXT}${BOLD_TEXT}🔧 Creating VPC network: mynetwork...${RESET_FORMAT}"
gcloud compute networks create mynetwork \
  --project=$PROJECT_ID \
  --subnet-mode=auto \
  --mtu=1460 \
  --bgp-routing-mode=regional
echo "${GREEN_TEXT}✅ Network creation completed.${RESET_FORMAT}"

# ────────────────────────────────────────────────────────────────
# 🖥️ Create First VM (Zone 1)
# ────────────────────────────────────────────────────────────────
echo "${BLUE_TEXT}${BOLD_TEXT}🖥️ Creating first VM in zone: $ZONE_1...${RESET_FORMAT}"
gcloud compute instances create mynet-us-vm \
  --project=$PROJECT_ID \
  --zone=$ZONE_1 \
  --machine-type=e2-micro \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=mynetwork \
  --metadata=enable-oslogin=true \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --create-disk=auto-delete=yes,boot=yes,device-name=mynet-us-vm,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230509,mode=rw,size=10,type=projects/$PROJECT_ID/zones/$ZONE_1/diskTypes/pd-balanced \
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
  --project=$PROJECT_ID \
  --zone=$ZONE_2 \
  --machine-type=e2-micro \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=mynetwork \
  --metadata=enable-oslogin=true \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --create-disk=auto-delete=yes,boot=yes,device-name=mynet-eu-vm,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230509,mode=rw,size=10,type=projects/$PROJECT_ID/zones/$ZONE_2/diskTypes/pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any
echo "${GREEN_TEXT}✅ Second VM created successfully.${RESET_FORMAT}"

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
echo

remove_temp_files() {
    echo "${YELLOW_TEXT}${BOLD_TEXT}Cleaning up temporary files...${RESET}"
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
echo -e "${WHITE_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
