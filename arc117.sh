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
echo "${CYAN_TEXT}${BOLD_TEXT}                             Tagging Dataplex Assets                    ${RESET_FORMAT}"
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

echo "${BLUE_TEXT}${BOLD_TEXT}---> Enable Services...${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT} Enabling required services (datacatalog.googleapis.com and dataplex.googleapis.com)... ${RESET_FORMAT}"
echo
gcloud services enable datacatalog.googleapis.com
gcloud services enable dataplex.googleapis.com
echo ""

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Create Dataplex Lake...${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}   Creating Dataplex Lake 'customer-engagements' in location ${REGION}  ${RESET_FORMAT}"
echo ""

gcloud dataplex lakes create customer-engagements \
   --location=$REGION \
   --display-name="Customer Engagements"
echo ""

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Create Dataplex Zone...${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}  Creating Dataplex Zone 'raw-event-data' in location ${REGION}  ${RESET_FORMAT}"
echo
gcloud dataplex zones create raw-event-data \
    --location=$REGION \
    --lake=customer-engagements \
    --display-name="Raw Event Data" \
    --type=RAW \
    --resource-location-type=SINGLE_REGION \
    --discovery-enabled

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Create Storage Bucket...${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT} Creating storage bucket 'gs://$ID' in location ${REGION} for the project '${ID}'  ${RESET_FORMAT}"
echo
gsutil mb -p $ID -c REGIONAL -l $REGION gs://$ID
echo ""

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Create Dataplex Asset...${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT} Creating Dataplex Asset 'raw-event-files' in location ${REGION}   ${RESET_FORMAT}"
echo ""

gcloud dataplex assets create raw-event-files \
--location=$REGION \
--lake=customer-engagements \
--zone=raw-event-data \
--display-name="Raw Event Files" \
--resource-type=STORAGE_BUCKET \
--resource-name=projects/my-project/buckets/${ID}

PROJECT_ID=$(gcloud config get-value project)  # Fetch the current project ID
URL="https://console.cloud.google.com/dataplex/templates/create?project=${PROJECT_ID}"

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Open Dataplex Templates URL...${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}Open the following URL:${RESET_FORMAT}"
echo "${WHITE_TEXT}${BOLD_TEXT} $URL ${RESET_FORMAT}"
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
