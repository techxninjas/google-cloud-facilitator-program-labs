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
echo "${CYAN_TEXT}${BOLD_TEXT}---------------------------------------------------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}           Consuming Customer Specific Datasets from Data Sharing Partners using BigQuery          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}  Task 2. Create an authorized view in the Data Publishing project: Data Publisher Project Console ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}---------------------------------------------------------------------------------------------------${RESET_FORMAT}"
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
echo "${MAGENTA_TEXT}${BOLD_TEXT}---> Getting User ID...${RESET_FORMAT}"
echo
read -p "Please enter Customer (Data Twin) Username: " TWIN_USERNAME
export TWIN_USERNAME="$TWIN_USERNAME"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating authorized view to access shared data...${RESET_FORMAT}"
echo "${GREEN_TEXT}This will create a view that filters records to only show New York (NY) state data.${RESET_FORMAT}"
echo

cat > view.py <<EOF_CP
from google.cloud import bigquery
client = bigquery.Client()
source_dataset_id = "data_publisher_dataset"
source_dataset_id_full = "{}.{}".format(client.project, source_dataset_id)
source_dataset = bigquery.Dataset(source_dataset_id_full)
view_id_a = "$DEVSHELL_PROJECT_ID.data_publisher_dataset.authorized_view"
view_a = bigquery.Table(view_id_a)
view_a.view_query = f"SELECT * FROM \`$SHARED_ID.demo_dataset.authorized_table\` WHERE state_code='NY' LIMIT 1000"
view_a = client.create_table(view_a)
access_entries = source_dataset.access_entries
access_entries.append(
bigquery.AccessEntry(None, "view", view_a.reference.to_api_repr())
)
source_dataset.access_entries = access_entries
source_dataset = client.update_dataset(
source_dataset, ["access_entries"]
)

print(f"Created {view_a.table_type}: {str(view_a.reference)}")
EOF_CP

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing Python code to create the authorized view...${RESET_FORMAT}"
echo

python3 view.py
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
echo "${GREEN_TEXT}${BOLD_TEXT}         Now, Login with Customer (Data Twin) Username       ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA Section
echo -e "${YELLOW_TEXT}${BOLD_TEXT}🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo ""
echo -e "${WHITE_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
