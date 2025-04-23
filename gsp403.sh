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
echo "${CYAN_TEXT}${BOLD_TEXT}   10th Game: Skills Boost Arcade Certification Zone April 2025   ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}  4th Lab: Build a BI Dashboard Using Looker Studio and BigQuery  ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}----------------------------------------------------------------${RESET_FORMAT}"
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

# Instructions for creating the 'Reports' dataset
echo "${BLUE_TEXT}---------------------------------------------------------------------${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the 'Reports' Dataset in BigQuery${RESET_FORMAT}"
echo "${BLUE_TEXT}---------------------------------------------------------------------${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}---> ---> Executing: ${BOLD_TEXT}bq mk Reports${RESET_FORMAT}"
bq mk Reports
echo

# Instructions for running the query
echo "${BLUE_TEXT}-----------------------------------------------------------------------------------------------------${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}---> Running the BigQuery Query to Populate the 'Trees' Table in 'Reports' Dataset${RESET_FORMAT}"
echo "${BLUE_TEXT}-----------------------------------------------------------------------------------------------------${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}---> ---> Executing the query...${RESET_FORMAT}"

bq query \
  --use_legacy_sql=false \
  --destination_table=$DEVSHELL_PROJECT_ID:Reports.Trees \
  --replace=false \
  --nouse_cache \
  "SELECT
    TIMESTAMP_TRUNC(plant_date, MONTH) as plant_month,
    COUNT(tree_id) AS total_trees,
    species,
    care_taker,
    address,
    site_info
  FROM
    \`bigquery-public-data.san_francisco_trees.street_trees\`
  WHERE
    address IS NOT NULL
    AND plant_date >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 365 DAY)
    AND plant_date < TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)
  GROUP BY
    plant_month,
    species,
    care_taker,
    address,
    site_info"

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
echo "${GREEN_TEXT}${BOLD_TEXT}            IF NOT DONE, SEE THE VIDEO CAREFULLY...          ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA Section
echo -e "${YELLOW_TEXT}${BOLD_TEXT}🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo ""
echo -e "${WHITE_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@techxninjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
