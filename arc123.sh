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
echo "${CYAN_TEXT}${BOLD_TEXT}     10th Game: Skills Boost Arcade Certification Zone April 2025      ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}                 6th Lab: SingleStore on Google Cloud                  ${RESET_FORMAT}"
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

echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling the 'Data Catalog API'${RESET_FORMAT}"
gcloud services enable datacatalog.googleapis.com
echo ""

echo "${YELLOW_TEXT}---> ---> Executing: ${BOLD_TEXT}bq mk Ecommerce${RESET_FORMAT}"
bq mk ecommerce
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling the 'Big Query Connection API'${RESET_FORMAT}"
gcloud services enable bigqueryconnection.googleapis.com

echo "${YELLOW_TEXT}---> ---> Executing: ${BOLD_TEXT}bq mk Connections${RESET_FORMAT}"
bq mk --connection --location=$REGION --project_id=$DEVSHELL_PROJECT_ID \
    --connection_type=CLOUD_RESOURCE customer_data_connection
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching service account ID from BigQuery connection...${RESET_FORMAT}"
CLOUD=$(bq show --connection $DEVSHELL_PROJECT_ID.$REGION.customer_data_connection | grep "serviceAccountId" | awk '{gsub(/"/, "", $8); print $8}')
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Cleaning up the fetched service account ID...${RESET_FORMAT}"
NEWs="${CLOUD%?}"
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Granting 'storage.objectViewer' role to the service account...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:$NEWs" \
    --role="roles/storage.objectViewer"
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating external table from CSV file in Cloud Storage...${RESET_FORMAT}"
bq mk --external_table_definition=gs://$DEVSHELL_PROJECT_ID-bucket/customer-online-sessions.csv \
ecommerce.customer_online_sessions
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Data Catalog tag template for sensitive data classification...${RESET_FORMAT}"
gcloud data-catalog tag-templates create sensitive_data_template \
    --location=$REGION \
    --display-name="Sensitive Data Template" \
    --field=id=has_sensitive_data,display-name="Has Sensitive Data",type=bool \
    --field=id=sensitive_data_type,display-name="Sensitive Data Type",type='enum(Location Info|Contact Info|None)'

cat > tag_file.json << EOF
  {
    "has_sensitive_data": TRUE,
    "sensitive_data_type": "Location Info"
  }
EOF

echo "${BLUE_TEXT}${BOLD_TEXT}---> Looking up Data Catalog entry for the BigQuery table...${RESET_FORMAT}"
ENTRY_NAME=$(gcloud data-catalog entries lookup '//bigquery.googleapis.com/projects/'$DEVSHELL_PROJECT_ID'/datasets/ecommerce/tables/customer_online_sessions' --format="value(name)")
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating and applying tag using the sensitive data template...${RESET_FORMAT}"
gcloud data-catalog tags create --entry=${ENTRY_NAME} \
    --tag-template=sensitive_data_template --tag-template-location=$REGION --tag-file=tag_file.json
echo ""

for i in {1..20}; do
    echo -ne "${CYAN_TEXT}⏳ Waiting ${i}/20 seconds to running Pub/Sub messages...\r${RESET_FORMAT}"
    sleep 1
done
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
