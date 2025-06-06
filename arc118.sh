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
echo "${CYAN_TEXT}${BOLD_TEXT}    10th Game: Skills Boost Arcade Certification Zone April 2025   ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}          3rd Lab: Get Started with Eventarc: Challenge Lab        ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}----------------------------------------------------------------${RESET_FORMAT}"
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

echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling required services on Google Cloud...${RESET_FORMAT}"
gcloud services enable run.googleapis.com
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling Cloud Run and Eventarc services...${RESET_FORMAT}"
gcloud services enable eventarc.googleapis.com
echo ""

# Set up Pub/Sub topic and subscription
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Pub/Sub topic...${RESET_FORMAT}"
gcloud pubsub topics create "$DEVSHELL_PROJECT_ID-topic"
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Pub/Sub subscription for the topic...${RESET_FORMAT}"
gcloud pubsub subscriptions create --topic "$DEVSHELL_PROJECT_ID-topic" "$DEVSHELL_PROJECT_ID-topic-sub"
echo ""

# Deploy the Cloud Run service
echo "${BLUE_TEXT}${BOLD_TEXT}---> Deploying Cloud Run service 'pubsub-events'...${RESET_FORMAT}"
gcloud run deploy pubsub-events \
  --image=gcr.io/cloudrun/hello \
  --platform=managed \
  --region="$LOCATION" \
  --allow-unauthenticated
echo ""

# Create Eventarc trigger to listen to Pub/Sub messages
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Eventarc trigger for Pub/Sub topic...${RESET_FORMAT}"
gcloud eventarc triggers create pubsub-events-trigger \
  --location="$LOCATION" \
  --destination-run-service=pubsub-events \
  --destination-run-region="$LOCATION" \
  --transport-topic="$DEVSHELL_PROJECT_ID-topic" \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished"
echo ""

# Send a test message to the Pub/Sub topic
echo "${BLUE_TEXT}${BOLD_TEXT}---> Publishing a test message to the Pub/Sub topic...${RESET_FORMAT}"
gcloud pubsub topics publish "$DEVSHELL_PROJECT_ID-topic" \
  --message="Test message"
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
