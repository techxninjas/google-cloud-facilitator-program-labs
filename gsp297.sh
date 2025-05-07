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
echo "${CYAN_TEXT}${BOLD_TEXT}                  Google Cloud Storage - Bucket Lock                    ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}------------------------------------------------------------------------${RESET_FORMAT}"
echo ""

# 🌍 Fetching Region
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔄 Fetching Region...${RESET_FORMAT}"
export LOCATION=$(gcloud compute project-info describe \
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

# Instructions before creating bucket
echo
export BUCKET=$(gcloud config get-value project)
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a bucket named 'gs://$BUCKET'...${RESET_FORMAT}"
echo
gsutil mb -l $region "gs://$BUCKET"
sleep 10

echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting retention policy...${RESET_FORMAT}"
gsutil retention set 10s "gs://$BUCKET"
gsutil retention get "gs://$BUCKET"


echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying dummy_transactions...${RESET_FORMAT}"
gsutil cp gs://spls/gsp297/dummy_transactions "gs://$BUCKET/"
gsutil ls -L "gs://$BUCKET/dummy_transactions"
sleep 10

echo "${BLUE_TEXT}${BOLD_TEXT}---> Locking retention policy...${RESET_FORMAT}"
gsutil retention lock "gs://$BUCKET/"


echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting temporary hold...${RESET_FORMAT}"
gsutil retention temp set "gs://$BUCKET/dummy_transactions"


echo "${BLUE_TEXT}${BOLD_TEXT}---> Removing dummy_transactions...${RESET_FORMAT}"
gsutil rm "gs://$BUCKET/dummy_transactions"


echo "${BLUE_TEXT}${BOLD_TEXT}---> Releasing temporary hold...${RESET_FORMAT}"
gsutil retention temp release "gs://$BUCKET/dummy_transactions"


echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting event-based hold as default...${RESET_FORMAT}"
gsutil retention event-default set "gs://$BUCKET/"


echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying dummy_loan...${RESET_FORMAT}"
gsutil cp gs://spls/gsp297/dummy_loan "gs://$BUCKET/"
gsutil ls -L "gs://$BUCKET/dummy_loan"


echo "${BLUE_TEXT}${BOLD_TEXT}---> Releasing event-based hold...${RESET_FORMAT}"
gsutil retention event release "gs://$BUCKET/dummy_loan"
gsutil ls -L "gs://$BUCKET/dummy_loan"

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
