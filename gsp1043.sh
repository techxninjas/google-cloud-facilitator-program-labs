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
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}  Consuming Customer Specific Datasets from Data Sharing Partners using BigQuery  ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}    Task 1. Created an authorized table: Data Sharing Partner Project Console     ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------------------------------${RESET_FORMAT}"
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

# Step 1: Get User IDs
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}---> Getting User IDs...${RESET_FORMAT}"
echo
read -p "Please enter Data Publisher Username: " PUBLISHER_USERNAME
echo
read -p "Please enter Customer (Data Twin) Username: " TWIN_USERNAME
export PUBLISHER_USERNAME="$PUBLISHER_USERNAME"
export TWIN_USERNAME="$TWIN_USERNAME"
echo

# Step 2: Create BigQuery Table
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating BigQuery Table with Top 10 Cities by Area...${RESET_FORMAT}"
export PROJECT_ID=$DEVSHELL_PROJECT_ID
export DATASET=demo_dataset
export TABLE=authorized_table

bq query \
--location=US \
--use_legacy_sql=false \
--destination_table=${PROJECT_ID}:${DATASET}.${TABLE} \
--replace \
--nouse_cache \
'SELECT * FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY state_code ORDER BY area_land_meters DESC) AS cities_by_area
  FROM `bigquery-public-data.geo_us_boundaries.zip_codes`
) cities
WHERE cities_by_area <= 10
ORDER BY cities.state_code
LIMIT 1000;' > /dev/null

# Step 3: Show Dataset Info
echo "${BLUE_TEXT}${BOLD_TEXT}---> Showing Dataset Info...${RESET_FORMAT}"
bq show --format=prettyjson ${PROJECT_ID}:${DATASET} > temp_dataset.json

# Step 4: Modify Dataset Access Policy
echo "${BOLD_TEXT}${YELLOW}Modifying Dataset Access Policy...${RESET_FORMAT}"
jq ".access += [
  {
    \"role\": \"READER\",
    \"userByEmail\": \"${PUBLISHER_USERNAME}\"
  },
  {
    \"role\": \"READER\",
    \"userByEmail\": \"${TWIN_USERNAME}\"
  }
]" temp_dataset.json > updated_dataset.json

# Step 5: Update Dataset Permissions
echo "${BLUE_TEXT}${BOLD_TEXT}---> Updating Dataset Permissions...${RESET_FORMAT}"
bq update --source=updated_dataset.json ${PROJECT_ID}:${DATASET}

# Step 6: Create IAM Policy File
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating IAM Policy File...${RESET_FORMAT}"
cat <<EOF > policy.json
{
  "bindings": [
    {
      "members": [
        "user:${PUBLISHER_USERNAME}",
        "user:${TWIN_USERNAME}"
      ],
      "role": "roles/bigquery.dataViewer"
    }
  ]
}
EOF

# Step 7: Set IAM Policy on Table
echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting IAM Policy on Table...${RESET_FORMAT}"
bq set-iam-policy ${PROJECT_ID}:${DATASET}.${TABLE} policy.json

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}               ✅ 1st TASK COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
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
echo "${GREEN_TEXT}${BOLD_TEXT}      Now, See the Video Carefully to do remaining Tasks      ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA Section
echo -e "${YELLOW_TEXT}${BOLD_TEXT}🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo ""
echo -e "${WHITE_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
