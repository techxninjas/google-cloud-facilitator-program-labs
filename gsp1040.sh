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
echo "${CYAN_TEXT}${BOLD_TEXT}---------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         BigLake: Qwik Start       ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}---------------------------------${RESET_FORMAT}"
echo ""

# Author: Aadil Latif
# Script: TechX Ninjas Lab Setup
# Version: 1.0

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

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a BigQuery connection named 'my-connection' in the 'US' location...${RESET_FORMAT}"
bq mk --connection --location=US --project_id=$PROJECT_ID --connection_type=CLOUD_RESOURCE my-connection
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Retrieving the service account associated with the connection...${RESET_FORMAT}"
SERVICE_ACCOUNT=$(bq show --format=json --connection $PROJECT_ID.US.my-connection | jq -r '.cloudResource.serviceAccountId')
echo "${YELLOW_TEXT}${BOLD_TEXT}Service Account ID:${RESET_FORMAT} ${CYAN_TEXT}${BOLD_TEXT}$SERVICE_ACCOUNT${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Granting the service account 'Storage Object Viewer' role to access data in your storage...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$SERVICE_ACCOUNT \
  --role=roles/storage.objectViewer
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a dataset named 'demo_dataset' in BigQuery...${RESET_FORMAT}"
bq mk demo_dataset
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating an external table definition for a CSV file in your storage bucket...${RESET_FORMAT}"
bq mkdef \
--autodetect \
--connection_id=$PROJECT_ID.US.my-connection \
--source_format=CSV \
"gs://$PROJECT_ID/invoice.csv" > /tmp/tabledef.json
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a BigLake table using the external table definition...${RESET_FORMAT}"
bq mk --external_table_definition=/tmp/tabledef.json --project_id=$PROJECT_ID demo_dataset.biglake_table
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a regular external table using the same definition...${RESET_FORMAT}"
bq mk --external_table_definition=/tmp/tabledef.json --project_id=$PROJECT_ID demo_dataset.external_table
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Getting the schema of the external table and save it to a file...${RESET_FORMAT}"
bq show --schema --format=prettyjson  demo_dataset.external_table > /tmp/schema
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Updating the external table with the schema we just retrieved...${RESET_FORMAT}"
bq update --external_table_definition=/tmp/tabledef.json --schema=/tmp/schema demo_dataset.external_table
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
