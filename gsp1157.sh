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
echo "${CYAN_TEXT}${BOLD_TEXT}----------------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}                 Implementing Security in Dataplex              ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}----------------------------------------------------------------${RESET_FORMAT}"
echo ""

# 🌍 Fetching Region
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔄 Fetching Location...${RESET_FORMAT}"
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")
echo ""

# 🆔 Fetching Project ID
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔍 Fetching Project ID...${RESET_FORMAT}"
PROJECT_ID=`gcloud config get-value project`
echo ""

# 🔢 Fetching Project Number
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔍 Fetching Project Number...${RESET_FORMAT}"
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
echo ""

echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔍 Fetching Pre-Requisuites...${RESET_FORMAT}"
export BUCKET_NAME="${PROJECT_ID}-bucket"
echo ""

# 💡 Start-Up Banner
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         🚀 INITIATING THE TASK EXECUTION...          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo ""

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Enabling the Dataplex API. This is a necessary step for using Dataplex services.${RESET_FORMAT}"
gcloud services enable dataplex.googleapis.com

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Enabling the Data Catalog API. This service helps in discovering and managing data assets.${RESET_FORMAT}"
gcloud services enable datacatalog.googleapis.com

echo
echo "${BLUE_TEXT}${BOLD_TEXT}The following command will create a new Dataplex lake named 'customer-info-lake' in the region: ${REGION}.${RESET_FORMAT}"
gcloud dataplex lakes create customer-info-lake \
    --location=$REGION \
    --display-name="Customer Info Lake"

echo
echo "${BLUE_TEXT}${BOLD_TEXT}Creating a RAW zone named 'customer-raw-zone' within the 'customer-info-lake'. This zone is for unprocessed data.${RESET_FORMAT}"
gcloud alpha dataplex zones create customer-raw-zone \
                        --location=$REGION --lake=customer-info-lake \
                        --resource-location-type=SINGLE_REGION --type=RAW \
                        --display-name="Customer Raw Zone"

echo
echo "${BLUE_TEXT}${BOLD_TEXT}This step involves creating a Dataplex asset named 'customer-online-sessions'. It links a storage bucket to the 'customer-raw-zone'.${RESET_FORMAT}"
gcloud dataplex assets create customer-online-sessions --location=$REGION \
                        --lake=customer-info-lake --zone=customer-raw-zone \
                        --resource-type=STORAGE_BUCKET \
                        --resource-name=projects/$PROJECT_ID/buckets/$PROJECT_ID-bucket \
                        --display-name="Customer Online Sessions"


echo
echo "${YELLOW_TEXT}${BOLD_TEXT}========================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}            NOW FOLLOW THE VIDEO STEPS FOR NEXT TASKS...      ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}             VIDEO LINK: https://youtu.be/35jZaJSnDXM      ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}========================================================${RESET_FORMAT}"
echo

echo "${CYAN_TEXT}${BOLD_TEXT}OPEN THIS LINK: ${RESET_FORMAT}""${BLUE_TEXT}${BOLD_TEXT}https://console.cloud.google.com/dataplex/secure?resourceName=projects%2F${PROJECT_ID}%2Flocations%2F$REGION%2Flakes%2Fcustomer-info-lake&project=${PROJECT_ID}""${RESET_FORMAT}"

for i in {1..60}; do
    echo -ne "${CYAN_TEXT}⏳ ${i}/60 seconds for further process\r${RESET_FORMAT}"
    sleep 1
done
echo

# Ask for confirmation
read -p "If you have completed the above step, enter Y to continue: " confirm

# Check input
if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
    echo "Uploading script to GCS..."
    curl -s https://raw.githubusercontent.com/TechXNinjas/google-cloud-facilitator-program-labs/main/gsp1157.sh | gsutil cp - gs://${BUCKET_NAME}/gsp1157.sh
    echo "✅ Script uploaded successfully to gs://${BUCKET_NAME}/gsp1157.sh"
else
    echo "❌ Step not confirmed. Exiting."
    exit 1
fi

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
echo "${GREEN_TEXT}${BOLD_TEXT}               ✅ ALL TASKS COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your progress."
echo "${GREEN_TEXT}${BOLD_TEXT} If it will be not completed, try again for successfully completion of the Assessment."
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
