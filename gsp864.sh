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
echo "${CYAN_TEXT}${BOLD_TEXT}         Redacting Critical Data with Sensitive Data Protection        ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}------------------------------------------------------------------------${RESET_FORMAT}"
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

BUCKET_NAME="gs://${PROJECT_ID}-bucket"

echo "${BLUE_TEXT}${BOLD_TEXT}---> Cloning the synthtool repository...${RESET_FORMAT}"
git clone https://github.com/googleapis/synthtool
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Installing dependencies in sample Node.js DLP fixture...${RESET_FORMAT}"
cd synthtool/tests/fixtures/nodejs-dlp/samples/ && npm install
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling required Google Cloud APIs...${RESET_FORMAT}"
gcloud services enable dlp.googleapis.com cloudkms.googleapis.com \
--project $PROJECT_ID

echo "${BLUE_TEXT}${BOLD_TEXT}---> Inspecting a string using DLP API...${RESET_FORMAT}"
node inspectString.js $PROJECT_ID "My email address is jenny@somedomain.com and you can call me at 555-867-5309" > inspected-string.txt
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Viewing inspected string output...${RESET_FORMAT}"
cat inspected-string.txt
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Viewing sample accounts.txt file...${RESET_FORMAT}"
cat resources/accounts.txt
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Inspecting a file for sensitive data...${RESET_FORMAT}"
node inspectFile.js $PROJECT_ID resources/accounts.txt > inspected-file.txt
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Viewing inspected file output...${RESET_FORMAT}"
cat inspected-file.txt
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Uploading inspected string and file to GCS bucket...${RESET_FORMAT}"
gsutil cp inspected-string.txt $BUCKET_NAME
gsutil cp inspected-file.txt $BUCKET_NAME
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> De-identifying sensitive info with masking...${RESET_FORMAT}"
node deidentifyWithMask.js $PROJECT_ID "My order number is F12312399. Email me at anthony@somedomain.com" > de-identify-output.txt
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Viewing de-identified output...${RESET_FORMAT}"
cat de-identify-output.txt
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Uploading de-identified output to GCS...${RESET_FORMAT}"
gsutil cp de-identify-output.txt $BUCKET_NAME
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Redacting a credit card number from text...${RESET_FORMAT}"
node redactText.js $PROJECT_ID  "Please refund the purchase to my credit card 4012888888881881" CREDIT_CARD_NUMBER > redacted-string.txt
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Viewing redacted string output...${RESET_FORMAT}"
cat redacted-string.txt
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Redacting phone number from image...${RESET_FORMAT}"
node redactImage.js $PROJECT_ID resources/test.png "" PHONE_NUMBER ./redacted-phone.png
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Redacting email address from image...${RESET_FORMAT}"
node redactImage.js $PROJECT_ID resources/test.png "" EMAIL_ADDRESS ./redacted-email.png
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Uploading redacted outputs to GCS bucket...${RESET_FORMAT}"
gsutil cp redacted-string.txt $BUCKET_NAME
gsutil cp redacted-phone.png $BUCKET_NAME
gsutil cp redacted-email.png $BUCKET_NAME
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
echo -e "${WHITE_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@techxninjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
