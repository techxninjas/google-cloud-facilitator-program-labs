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
echo "${CYAN_TEXT}${BOLD_TEXT}        Use APIs to Work with Cloud Storage: Challenge Lab             ${RESET_FORMAT}"
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

# Step 1: Create bucket1.json
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating bucket1.json...${RESET_FORMAT}"
cat > bucket1.json <<EOF
{  
   "name": "$DEVSHELL_PROJECT_ID-bucket-1",
   "location": "us",
   "storageClass": "multi_regional"
}
EOF

# Step 2: Create bucket1
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating bucket1...${RESET_FORMAT}"
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" --data-binary @bucket1.json "https://storage.googleapis.com/storage/v1/b?project=$DEVSHELL_PROJECT_ID"
echo ""

echo "${GREEN_TEXT}${BOLD_TEXT}---> Bucket1 has been created. Now creating Bucket2.${RESET_FORMAT}"
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating bucket2.json...${RESET_FORMAT}"
cat > bucket2.json <<EOF
{  
   "name": "$DEVSHELL_PROJECT_ID-bucket-2",
   "location": "us",
   "storageClass": "multi_regional"
}
EOF

# Step 4: Create bucket2
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating bucket2...${RESET_FORMAT}"
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" --data-binary @bucket2.json "https://storage.googleapis.com/storage/v1/b?project=$DEVSHELL_PROJECT_ID"

# Instructions before Step 5
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT}---> Bucket2 has been created. Now Downloading the techxninjas.jpeg file.${RESET_FORMAT}"
echo ""

# Step 5: Download the image file
echo "${BLUE_TEXT}${BOLD_TEXT}---> Downloading the image file...${RESET_FORMAT}"
curl -LO https://raw.githubusercontent.com/techxninjas/google-cloud-facilitator-program-labs/tree/main/Skill%20Badges/Use%20APIs%20to%20Work%20with%20Cloud%20Storage/techxninjas.jpeg

# Instructions before Step 6
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT}---> Image file has been downloaded. Now Uploading image to bucket1.${RESET_FORMAT}"
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Uploading the image file to bucket1...${RESET_FORMAT}"
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: image/jpeg" --data-binary @techxninjas.jpeg "https://storage.googleapis.com/upload/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o?uploadType=media&name=techxninjas.jpeg"

echo ""
echo "${GREEN_TEXT}${BOLD_TEXT}---> Image has been uploaded to bucket1. Now copying it to bucket2.${RESET_FORMAT}"
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying the image from bucket1 to bucket2...${RESET_FORMAT}"
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" --data '{"destination": "$DEVSHELL_PROJECT_ID-bucket-2"}' "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o/techxninjas.jpeg/copyTo/b/$DEVSHELL_PROJECT_ID-bucket-2/o/techxninjas.jpeg"

echo ""
echo "${GREEN_TEXT}${BOLD_TEXT}---> Image copied to bucket2. Now Setting public access for image in bucket1.${RESET_FORMAT}"
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting public access for the image...${RESET_FORMAT}"
cat > public_access.json <<EOF
{
  "entity": "allUsers",
  "role": "READER"
}
EOF

curl -X POST --data-binary @public_access.json -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o/techxninjas.jpeg/acl"

echo ""
echo "${BLUE_TEXT}${BOLD_TEXT}---> Public access set. Now Deleting the image from bucket1.${RESET_FORMAT}"
echo ""

echo "${BLUE_TEXT}${CYAN_TEXT}Deleting the image from bucket1...${RESET_FORMAT}"
curl -X DELETE -H "Authorization: Bearer $(gcloud auth print-access-token)" "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o/techxninjas.jpeg"

echo ""
echo "${BLUE_TEXT}${BOLD_TEXT}---> Image deleted from bucket1. Now deleting bucket1.${RESET_FORMAT}"
echo ""

echo "${BOLD_TEXT}${BLUE_TEXT}Deleting bucket1...${RESET_FORMAT}"
curl -X DELETE -H "Authorization: Bearer $(gcloud auth print-access-token)" "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1"

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
echo ""

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
echo "${GREEN_TEXT}${BOLD_TEXT}          ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!          ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA Section
echo -e "${YELLOW_TEXT}${BOLD_TEXT}🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo ""
echo -e "${WHITE_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@techxninjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
