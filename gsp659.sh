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
echo "${CYAN_TEXT}${BOLD_TEXT}                Deploy Your Website on Cloud Run                      ${RESET_FORMAT}"
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

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Cloning the 'monolith-to-microservices' repository from GitHub...${RESET_FORMAT}"
git clone https://github.com/googlecodelabs/monolith-to-microservices.git

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Navigating into the cloned 'monolith-to-microservices' directory...${RESET_FORMAT}"
cd ~/monolith-to-microservices

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Running the setup script for the project...${RESET_FORMAT}"
./setup.sh

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Changing directory to 'monolith' application folder...${RESET_FORMAT}"
cd ~/monolith-to-microservices/monolith

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a new Artifact Registry Docker repository named 'monolith-demo'...${RESET_FORMAT}"
gcloud artifacts repositories create monolith-demo --location=$REGION --repository-format=docker --description="Subscribe to techcps" 

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Configuring Docker to authenticate with Artifact Registry in region: ${WHITE_TEXT}${REGION}${RESET_FORMAT}"
gcloud auth configure-docker $REGION-docker.pkg.dev

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling necessary Google Cloud services: Artifact Registry, Cloud Build, and Cloud Run APIs...${RESET_FORMAT}"
gcloud services enable artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    run.googleapis.com

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Building the first version (1.0.0) of the monolith Docker image using Cloud Build...${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}---> Image will be tagged as: ${WHITE_TEXT}$REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0${RESET_FORMAT}"
gcloud builds submit --tag $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Deploying the monolith application (version 1.0.0) to Cloud Run...${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}---> Service name: monolith, Region: ${WHITE_TEXT}${REGION}${CYAN_TEXT}, Allow unauthenticated access.${RESET_FORMAT}"
gcloud run deploy monolith --image $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0 --allow-unauthenticated --region $REGION

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Updating the Cloud Run service 'monolith' to set concurrency to 1...${RESET_FORMAT}"
gcloud run deploy monolith --image $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0 --allow-unauthenticated --region $REGION --concurrency 1

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Updating the Cloud Run service 'monolith' to set concurrency to 80...${RESET_FORMAT}"
gcloud run deploy monolith --image $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0 --allow-unauthenticated --region $REGION --concurrency 80

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Navigating to the React app's 'Home' page source directory...${RESET_FORMAT}"
cd ~/monolith-to-microservices/react-app/src/pages/Home

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Replacing 'index.js' with 'index.js.new' to update the React app's Home page index.js...${RESET_FORMAT}"
mv index.js.new index.js

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Displaying the content of the updated 'index.js' file...${RESET_FORMAT}"
cat ~/monolith-to-microservices/react-app/src/pages/Home/index.js

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Navigating to the main 'react-app' directory...${RESET_FORMAT}"
cd ~/monolith-to-microservices/react-app

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Building the React application for the monolith setup...${RESET_FORMAT}"
npm run build:monolith

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Returning to the 'monolith' application directory...${RESET_FORMAT}"
cd ~/monolith-to-microservices/monolith

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Building the second version (2.0.0) of the monolith Docker image with updated frontend...${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}---> Image will be tagged as: ${WHITE_TEXT}$REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:2.0.0${RESET_FORMAT}"
gcloud builds submit --tag $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:2.0.0

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Deploying the updated monolith application (version 2.0.0) to Cloud Run...${RESET_FORMAT}"
gcloud run deploy monolith --image $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:2.0.0 --allow-unauthenticated --region $REGION
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
