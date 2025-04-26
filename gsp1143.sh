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
echo "${CYAN_TEXT}${BOLD_TEXT}------------------------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}                      Dataplex: Qwik Start - Console                  ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}------------------------------------------------------------------------${RESET_FORMAT}"
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

# Enable Dataplex API
echo "${BOLD_TEXT}${CYAN_TEXT}Enabling Dataplex API...${RESET_FORMAT}"
gcloud services enable dataplex.googleapis.com

# Create Dataplex Lake
echo "${BOLD_TEXT}${CYAN_TEXT}Creating Dataplex Lake 'sensors'...${RESET_FORMAT}"
gcloud alpha dataplex lakes create sensors \
 --location=$REGION \
 --labels=k1=v1,k2=v2,k3=v3 

# Create Dataplex Zone
echo "${BOLD_TEXT}${CYAN_TEXT}Creating Dataplex Zone 'temperature-raw-data'...${RESET_FORMAT}"
gcloud alpha dataplex zones create temperature-raw-data \
            --location=$REGION --lake=sensors \
            --resource-location-type=SINGLE_REGION --type=RAW

# Create Storage Bucket
echo "${BOLD_TEXT}${CYAN_TEXT}Creating a Storage Bucket...${RESET_FORMAT}"
gsutil mb -l $REGION gs://$DEVSHELL_PROJECT_ID

# Create Dataplex Asset
echo "${BOLD_TEXT}${CYAN_TEXT}Creating Dataplex Asset 'measurements'...${RESET_FORMAT}"
gcloud dataplex assets create measurements --location=$REGION \
            --lake=sensors --zone=temperature-raw-data \
            --resource-type=STORAGE_BUCKET \
            --resource-name=projects/$DEVSHELL_PROJECT_ID/buckets/$DEVSHELL_PROJECT_ID

# Cleanup: Delete Dataplex Asset
echo "${BOLD_TEXT}${RED_TEXT}Deleting Dataplex Asset 'measurements'...${RESET_FORMAT}"
gcloud dataplex assets delete measurements --zone=temperature-raw-data --lake=sensors --location=$REGION --quiet

# Cleanup: Delete Dataplex Zone
echo "${BOLD_TEXT}${RED_TEXT}Deleting Dataplex Zone 'temperature-raw-data'...${RESET_FORMAT}"
gcloud dataplex zones delete temperature-raw-data --lake=sensors --location=$REGION --quiet

# Cleanup: Delete Dataplex Lake
echo "${BOLD_TEXT}${RED_TEXT}Deleting Dataplex Lake 'sensors'...${RESET_FORMAT}"
gcloud dataplex lakes delete sensors --location=$REGION --quiet


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
echo -e "${WHITE_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@techxninjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
