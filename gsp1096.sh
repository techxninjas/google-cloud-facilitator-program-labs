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

# Create GCS bucket
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Google Cloud Storage bucket${RESET}"
gcloud storage buckets create gs://$GOOGLE_CLOUD_PROJECT --location=$REGION
echo ""

# Copy 'drivers' folder from public GCS to your GCS bucket
echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying 'drivers' folder to your GCS bucket${RESET}"
gcloud storage cp -r gs://configuring-singlestore-on-gcp/drivers gs://$GOOGLE_CLOUD_PROJECT
echo ""

# Copy 'trips' folder from public GCS to your GCS bucket
echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying 'trips' folder to your GCS bucket${RESET}"
gcloud storage cp -r gs://configuring-singlestore-on-gcp/trips gs://$GOOGLE_CLOUD_PROJECT
echo ""

# Copy 'neighborhoods.csv' to your GCS bucket
echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying 'neighborhoods.csv' file to your GCS bucket${RESET}"
gcloud storage cp gs://configuring-singlestore-on-gcp/neighborhoods.csv gs://$GOOGLE_CLOUD_PROJECT
echo ""

# Run Dataflow job to stream GCS JSON to Pub/Sub
echo "${BLUE_TEXT}${BOLD_TEXT}---> Running Dataflow job to stream JSON files from GCS to Pub/Sub${RESET}"
gcloud dataflow jobs run "GCStoPS-clone" \
  --gcs-location=gs://dataflow-templates-$REGION/latest/Stream_GCS_Text_to_Cloud_PubSub \
  --region=$REGION \
  --parameters \
inputFilePattern=gs://$DEVSHELL_PROJECT_ID-dataflow/input/*.json,\
outputTopic=projects/$(gcloud config get-value project)/topics/Taxi
echo ""

# Pull messages from Pub/Sub subscription
echo "${BLUE_TEXT}${BOLD_TEXT}---> Pulling messages from 'Taxi-sub' Pub/Sub subscription${RESET}"
gcloud pubsub subscriptions pull projects/$(gcloud config get-value project)/subscriptions/Taxi-sub \
--limit=10 --auto-ack
echo ""

# Run Dataflow Flex Template to stream Pub/Sub to GCS
echo "${BLUE_TEXT}${BOLD_TEXT}---> Running Dataflow Flex Template to write Pub/Sub messages to GCS${RESET}"
gcloud dataflow flex-template run pstogcs \
  --template-file-gcs-location=gs://dataflow-templates-$REGION/latest/flex/Cloud_PubSub_to_GCS_Text_Flex \
  --region=$REGION \
  --parameters \
inputSubscription=projects/$(gcloud config get-value project)/subscriptions/Taxi-sub,\
outputDirectory=gs://$DEVSHELL_PROJECT_ID,\
outputFilenamePrefix=output
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
