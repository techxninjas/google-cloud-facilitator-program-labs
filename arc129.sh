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
echo "${CYAN_TEXT}${BOLD_TEXT}------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         Secure BigLake Data: Challenge Lab       ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}------------------------------------------------${RESET_FORMAT}"
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

# Instruction before getting user input
read -p "${MAGENTA_TEXT}${BOLD_TEXT}Enter User 2 (Check Task 3 of your Lab): ${RESET_FORMAT}" USER_2
echo ""

# Step 1: Fetch taxonomy & plocy details
echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching taxonomy name, ID & policy...${RESET_FORMAT}"
export TAXONOMY_NAME=$(gcloud data-catalog taxonomies list \
  --location=us \
  --project=$DEVSHELL_PROJECT_ID \
  --format="value(displayName)" \
  --limit=1)
echo

export TAXONOMY_ID=$(gcloud data-catalog taxonomies list \
  --location=us \
  --format="value(name)" \
  --filter="displayName=$TAXONOMY_NAME" | awk -F'/' '{print $6}')

export POLICY_TAG=$(gcloud data-catalog taxonomies policy-tags list \
  --location=us \
  --taxonomy=$TAXONOMY_ID \
  --format="value(name)" \
  --limit=1)

# Step 2: Create BigQuery dataset
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the BigQuery dataset...${RESET_FORMAT}"
bq mk online_shop
echo

# Step 3: Create BigQuery connection
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a BigQuery connection...${RESET_FORMAT}"
bq mk --connection --location=US --project_id=$DEVSHELL_PROJECT_ID --connection_type=CLOUD_RESOURCE user_data_connection
echo

# Step 4: Grant the service account permission to read Cloud Storage files
echo "${BLUE_TEXT}${BOLD_TEXT}---> Granting service account permissions to read Cloud Storage...${RESET_FORMAT}"
export SERVICE_ACCOUNT=$(bq show --format=json --connection $DEVSHELL_PROJECT_ID.US.user_data_connection | jq -r '.cloudResource.serviceAccountId')
echo

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member=serviceAccount:$SERVICE_ACCOUNT \
  --role=roles/storage.objectViewer
echo

# Step 5: Create a table definition for the CSV file
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating BigQuery table definition from Cloud Storage file...${RESET_FORMAT}"
bq mkdef \
--autodetect \
--connection_id=$DEVSHELL_PROJECT_ID.US.user_data_connection \
--source_format=CSV \
"gs://$DEVSHELL_PROJECT_ID-bucket/user-online-sessions.csv" > /tmp/tabledef.json
echo

# Step 6: Create a BigLake table in the dataset
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a BigLake table in the BigQuery dataset...${RESET_FORMAT}"
bq mk --external_table_definition=/tmp/tabledef.json \
--project_id=$DEVSHELL_PROJECT_ID \
online_shop.user_online_sessions
echo

# Step 7: Create schema for the table
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating schema for the BigLake table...${RESET_FORMAT}"
cat > schema.json << EOM
[
  {
    "mode": "NULLABLE",
    "name": "ad_event_id",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "user_id",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "uri",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "traffic_source",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "zip",
    "policyTags": {
      "names": [
        "$POLICY_TAG"
      ]
    },
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "event_type",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "state",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "country",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "city",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "latitude",
    "policyTags": {
      "names": [
        "$POLICY_TAG"
      ]
    },
    "type": "FLOAT"
  },
  {
    "mode": "NULLABLE",
    "name": "created_at",
    "type": "TIMESTAMP"
  },
  {
    "mode": "NULLABLE",
    "name": "ip_address",
    "policyTags": {
      "names": [
        "$POLICY_TAG"
      ]
    },
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "session_id",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "longitude",
    "policyTags": {
      "names": [
        "$POLICY_TAG"
      ]
    },
    "type": "FLOAT"
  },
  {
    "mode": "NULLABLE",
    "name": "id",
    "type": "INTEGER"
  }
]
EOM
echo

# Step 8: Update the schema for the BigLake table
echo "${BLUE_TEXT}${BOLD_TEXT}---> Updating schema for the 'user_online_sessions' table...${RESET_FORMAT}"
bq update --schema schema.json $DEVSHELL_PROJECT_ID:online_shop.user_online_sessions
echo

# Step 9: Run a query to exclude sensitive information
echo "${BLUE_TEXT}${BOLD_TEXT}---> Running query to exclude sensitive columns...${RESET_FORMAT}"
bq query --use_legacy_sql=false --format=csv \
"SELECT * EXCEPT(zip, latitude, ip_address, longitude) 
FROM \`${DEVSHELL_PROJECT_ID}.online_shop.user_online_sessions\`"
echo

# Step 10: Remove IAM policy binding
# Conditionally remove policy only if USER_2 is not empty
if [[ -n "$USER_2" ]]; then
    echo "${YELLOW_TEXT}${BOLD_TEXT}---> Removing IAM policy binding for user $USER_2...${RESET_FORMAT}"
    gcloud projects remove-iam-policy-binding ${DEVSHELL_PROJECT_ID} \
        --member="user:$USER_2" \
        --role="roles/storage.objectViewer"
else
    echo "${YELLOW_TEXT}${BOLD_TEXT}Skipping IAM policy removal because no user was specified...${RESET_FORMAT}"
fi
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
