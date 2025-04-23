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
echo "${BRIGHT_PURPLE}${BOLD}----------------------------------------------------------------${RESET_FORMAT}"
echo "${BRIGHT_CYAN}${BOLD}    10th Game: Skills Boost Arcade Certification Zone April 2025   ${RESET_FORMAT}"
echo "${BRIGHT_CYAN}${BOLD}           1st Lab: Cloud Storage: Qwik Start - CLI/SDK           ${RESET_FORMAT}"
echo "${BRIGHT_PURPLE}${BOLD}----------------------------------------------------------------${RESET_FORMAT}"
echo ""

# 🌍 Fetching Region
echo "${BRIGHT_GREEN}${BOLD}🔄 Fetching Region...${RESET_FORMAT}"
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

# 🗺️ Fetching Zone
echo "${BRIGHT_GREEN}${BOLD}🔄 Fetching Zone...${RESET_FORMAT}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# 🆔 Fetching Project ID
echo "${BRIGHT_GREEN}${BOLD}🔍 Fetching Project ID...${RESET_FORMAT}"
PROJECT_ID=`gcloud config get-value project`

# 🔢 Fetching Project Number
echo "${BRIGHT_GREEN}${BOLD}🔍 Fetching Project Number...${RESET_FORMAT}"
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

# 💡 Start-Up Banner
echo "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo "${BRIGHT_CYAN}${BOLD}         🚀 INITIATING THE TASK EXECUTION...          ${RESET_FORMAT}"
echo "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET_FORMAT}"
echo ""

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Creating a Cloud Storage bucket...${RESET_FORMAT}"
gsutil mb gs://$DEVSHELL_PROJECT_ID

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Downloading the Ada Lovelace image...${RESET_FORMAT}"
curl https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Ada_Lovelace_portrait.jpg/800px-Ada_Lovelace_portrait.jpg --output ada.jpg

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Copying the image to the Cloud Storage bucket...${RESET_FORMAT}"
gsutil cp ada.jpg gs://$DEVSHELL_PROJECT_ID

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Copying the image from the Cloud Storage bucket to the local directory...${RESET_FORMAT}"
gsutil cp -r gs://$DEVSHELL_PROJECT_ID/ada.jpg .

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Creating 'image-folder' in the bucket and copying image inside it...${RESET_FORMAT}"
gsutil cp gs://$DEVSHELL_PROJECT_ID/ada.jpg gs://$DEVSHELL_PROJECT_ID/image-folder/

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Setting access control for the image in Cloud Storage...${RESET_FORMAT}"
gsutil acl ch -u AllUsers:R gs://$DEVSHELL_PROJECT_ID/ada.jpg

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
    echo "${YELLOW_TEXT}${BOLD}Cleaning up temporary files...${RESET}"
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
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}          ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!          ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA Section
echo -e "${YELLOW_TEXT}${BOLD}🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo ""
echo -e "${RED_TEXT}${BOLD}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET_FORMAT}"
echo ""
echo -e "${WHITE_TEXT}${BOLD}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
