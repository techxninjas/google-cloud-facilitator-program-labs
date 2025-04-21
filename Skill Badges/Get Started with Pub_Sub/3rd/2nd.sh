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

# 🚨 Welcome Message
echo "${CYAN_TEXT}${BOLD}🚀===========================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}        3rd Lab: Get Started with Pub/Sub: Challenge Lab      ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}           2nd Skill Badge: Get Started with Pub/Sub          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}===========================================================🚀${RESET_FORMAT}"
echo ""

# 🚀 Task Execution Init
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}         🚀 INITIATING THE TASK EXECUTION...          ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

# 🌍 Fetching Region
echo "${BRIGHT_GREEN}${BOLD}🔄 Fetching Region...${RESET_FORMAT}"
export LOCATION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

export MSG_BODY='Hello World!'

echo
echo "${BLUE_TEXT}${BOLD_TEXT}Creating a Pub/Sub topic to publish messages...${RESET_FORMAT}"
echo
gcloud pubsub topics create cloud-pubsub-topic

echo
echo "${CYAN_TEXT}${BOLD_TEXT}Creating a subscription to receive messages from our topic...${RESET_FORMAT}"
echo
gcloud pubsub subscriptions create cloud-pubsub-subscription --topic=cloud-pubsub-topic

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}Enabling the Cloud Scheduler service...${RESET_FORMAT}"
echo
gcloud services enable cloudscheduler.googleapis.com

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Creating a scheduler job that publishes messages every minute...${RESET_FORMAT}"
echo
gcloud scheduler jobs create pubsub cron-scheduler-job \
  --location=$LOCATION \
  --schedule="* * * * *" \
  --topic=cloud-pubsub-topic \
  --message-body="Hello World!"

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Pulling messages from our subscription to verify delivery...${RESET_FORMAT}"
echo
gcloud pubsub subscriptions pull cloud-pubsub-subscription --limit 5

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}               ✅ ALL TASKS COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your progress."
echo "${GREEN_TEXT}${BOLD_TEXT} If it will be not completed, try again for successfully completion of the Assessment."
sleep 10
echo ""

remove_temp_files() {
    echo "${YELLOW}${BOLD}Cleaning up temporary files...${RESET}"
    for file in *; do
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            [[ -f "$file" ]] && rm "$file" && echo "Removed: $file"
        fi
    done
}
remove_temp_files

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}          ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!          ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA Section
echo -e "${YELLOW_TEXT}${BOLD}🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo -e "${RED_TEXT}${BOLD}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD}Follow me on LinkedIn:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.linkedin.com/in/iaadillatif${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD}LinkedIn Page:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.linkedin.com/company/techxninjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
