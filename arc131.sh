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
echo "${CYAN_TEXT}${BOLD_TEXT}            Using the Google Cloud Speech API Challenge Lab          ${RESET_FORMAT}"
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

export ZONE=$(gcloud compute instances list lab-vm --format 'csv[no-heading](zone)')
gcloud compute ssh lab-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

# 💡 Start-Up Banner
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         🚀 INITIATING THE TASK EXECUTION...          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo ""

# Instructions for API Key
read -p "${CYAN_TEXT}${BOLD_TEXT}Enter your Google Cloud API Key: ${RESET_FORMAT}" USER_API_KEY

# Input Validation
while [[ -z "$USER_API_KEY" ]]; do
    echo "${RED_TEXT}${BOLD_TEXT}ERROR: API Key cannot be empty. Please enter a valid API Key.${RESET_FORMAT}"
    read -p "${BLUE_TEXT}${BOLD_TEXT}Enter your Google Cloud API Key: ${RESET_FORMAT}" USER_API_KEY
done

export API_KEY="$USER_API_KEY"

echo "${GREEN_TEXT}${BOLD_TEXT}API Key Set Successfully!${RESET_FORMAT}"
echo ""

# Taking user input for file names
read -p "${BLUE_TEXT}${BOLD_TEXT}Enter request file name for English (See in Task 2, Step 3): ${RESET_FORMAT}" REQUEST_FILE_A
read -p "${BLUE_TEXT}${BOLD_TEXT}Enter response file name for English (See in Task 2, Step 3): ${RESET_FORMAT}" RESPONSE_FILE_A
read -p "${BLUE_TEXT}${BOLD_TEXT}Enter request file name for Spanish (See in Task 3, Step 3): ${RESET_FORMAT}" REQUEST_FILE_B
read -p "${BLUE_TEXT}${BOLD_TEXT}Enter response file name for Spanish (See in Task 3, Step 3): ${RESET_FORMAT}" RESPONSE_FILE_B

# Display selected file names
echo -e "${CYAN_TEXT}${BOLD_TEXT}REQUEST FILE FOR ENGLISH: $REQUEST_FILE_A${RESET_FORMAT}"
echo -e "${CYAN_TEXT}${BOLD_TEXT}RESPONSE FILE FOR ENGLISH: $RESPONSE_FILE_A${RESET_FORMAT}"
echo -e "${CYAN_TEXT}${BOLD_TEXT}REQUEST FILE FOR SPANISH: $REQUEST_FILE_B${RESET_FORMAT}"
echo -e "${CYAN_TEXT}${BOLD_TEXT}RESPONSE FILE FOR SPANISH: $RESPONSE_FILE_B${RESET_FORMAT}"

# Exporting variables
export REQUEST_CP2=$REQUEST_FILE_A
export RESPONSE_CP2=$RESPONSE_FILE_A
export REQUEST_SP_CP3=$REQUEST_FILE_B
export RESPONSE_SP_CP3=$RESPONSE_FILE_B

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Request payload for English Speech Recognition...${RESET_FORMAT}"

cat > "$REQUEST_CP2" <<EOF
{
  "config": {
    "encoding": "LINEAR16",
    "languageCode": "en-US",
    "audioChannelCount": 2
  },
  "audio": {
    "uri": "gs://spls/arc131/question_en.wav"
  }
}
EOF

echo "${GREEN_TEXT}${BOLD_TEXT}REQUEST FILE FOR TASK 2 CREATED SUCCESSFULLY!${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Sending Request for English Speech Recognition...${RESET_FORMAT}"

curl -s -X POST -H "Content-Type: application/json" --data-binary @"$REQUEST_CP2" \
"https://speech.googleapis.com/v1/speech:recognize?key=$API_KEY" > $RESPONSE_CP2

echo "${GREEN_TEXT}${BOLD_TEXT}RESPONSE FILE FOR TASK 2 CREATED SUCCESSFULLY!${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Request payload for Spanish Speech Recognition...${RESET_FORMAT}"

cat > "$REQUEST_SP_CP3" <<EOF
{
  "config": {
    "encoding": "FLAC",
    "languageCode": "es-ES"
  },
  "audio": {
    "uri": "gs://spls/arc131/multi_es.flac"
  }
}
EOF

echo "${GREEN_TEXT}${BOLD_TEXT}REQUEST FILE FOR TASK 3 CREATED SUCCESSFULLY!${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Sending Request for Spanish Speech Recognition...${RESET_FORMAT}"

curl -s -X POST -H "Content-Type: application/json" --data-binary @"$REQUEST_SP_CP3" \
"https://speech.googleapis.com/v1/speech:recognize?key=$API_KEY" > $RESPONSE_SP_CP3

echo "${GREEN_TEXT}${BOLD_TEXT}RESPONSE FILE FOR TASK 3 CREATED SUCCESSFULLY!${RESET_FORMAT}"
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
echo -e "${WHITE_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
