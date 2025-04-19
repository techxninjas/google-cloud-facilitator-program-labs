#!/bin/bash

# Define color variables
YELLOW_COLOR=$'\033[0;33m'
NO_COLOR=$'\033[0m'
BACKGROUND_RED=`tput setab 1`
GREEN_TEXT=$'\033[0;32m'
RED_TEXT=`tput setaf 1`
BOLD_TEXT=`tput bold`
RESET_FORMAT=`tput sgr0`
BLUE_TEXT=`tput setaf 4`

# 🚀 Clear Screen
clear

# 🚨 Welcome Message
echo "${CYAN_TEXT}${BOLD}🚀====================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD} 8th Lab: The Basics of Google Cloud Compute: Challenge Lab ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}      Level 2: Cloud Infrastructure & API Essentials    ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}====================================================🚀${RESET_FORMAT}"
echo ""

# 🚀 Task Execution Init
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}         🚀 INITIATING THE TASK EXECUTION...          ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

# Get the default compute zone for the current project
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")
gcloud config set compute/zone "$ZONE"

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [[ -z "$PROJECT_ID" ]]; then
    echo "${RED_TEXT}${BOLD_TEXT}ERROR: No project ID found. Set your project ID using 'gcloud config set project PROJECT_ID'.${RESET_FORMAT}"
    exit 1
fi

# Define bucket name
BUCKET_NAME="${PROJECT_ID}-bucket"
echo

# Check if the bucket already exists
if gsutil ls -b "gs://${BUCKET_NAME}" >/dev/null 2>&1; then
    echo "${YELLOW_TEXT}${BOLD_TEXT}Bucket '${BUCKET_NAME}' already exists.${RESET_FORMAT}"
else
    # Create the Cloud Storage bucket in the US multi-region
    echo "${BLUE_TEXT}${BOLD_TEXT}Creating Cloud Storage bucket: ${BUCKET_NAME}${RESET_FORMAT}"
    if gcloud storage buckets create "gs://${BUCKET_NAME}" --location=US --uniform-bucket-level-access; then
        echo "${GREEN_TEXT}${BOLD_TEXT}Bucket '${BUCKET_NAME}' created successfully.${RESET_FORMAT}"
    else
        echo "${RED_TEXT}${BOLD_TEXT}Failed to create bucket '${BUCKET_NAME}'. Check your permissions and try again.${RESET_FORMAT}"
        exit 1
    fi
fi

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Creating the Compute Engine Instance 'my-instance' ========================== ${RESET_FORMAT}"
echo

gcloud compute instances create my-instance \
    --machine-type=e2-medium \
    --zone=$ZONE \
    --image-project=debian-cloud \
    --image-family=debian-11 \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-balanced \
    --create-disk=size=100GB,type=pd-standard,mode=rw,device-name=additional-disk \
    --tags=http-server

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Creating a Persistent Disk 'mydisk' ========================== ${RESET_FORMAT}"
echo
gcloud compute disks create mydisk \
    --size=200GB \
    --zone=$ZONE

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Attaching 'mydisk' to 'my-instance' ========================== ${RESET_FORMAT}"
echo
gcloud compute instances attach-disk my-instance \
    --disk=mydisk \
    --zone=$ZONE

echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for 15 seconds for the changes to take effect...${RESET_FORMAT}"
sleep 15

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Preparing the 'prepare_disk.sh' script ========================== ${RESET_FORMAT}"
echo
cat > prepare_disk.sh <<'EOF_END'

sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx

EOF_END

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Copying the script to the instance ========================== ${RESET_FORMAT}"
echo

gcloud compute scp prepare_disk.sh my-instance:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Executing the script on the instance ========================== ${RESET_FORMAT}"
echo

gcloud compute ssh my-instance --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/prepare_disk.sh"
echo

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
