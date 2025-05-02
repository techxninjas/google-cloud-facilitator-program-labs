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
echo "${CYAN_TEXT}${BOLD_TEXT}   Create a Streaming Data Lake on Cloud Storage: Challenge Lab  ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}----------------------------------------------------------------${RESET_FORMAT}"
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

# 💡 Start-Up Banner
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         🚀 INITIATING THE TASK EXECUTION...          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo ""

# Enable required Google Cloud services
echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling required Google Cloud services${RESET_FORMAT}"
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  osconfig.googleapis.com \
  pubsub.googleapis.com
echo ""

# Enable required Google Cloud services
echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling required Google Cloud services${RESET_FORMAT}"
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  osconfig.googleapis.com \
  pubsub.googleapis.com
echo ""

# Grant Pub/Sub Publisher role to the KMS service account
echo "${BLUE_TEXT}${BOLD_TEXT}---> Granting Pub/Sub Publisher role to the KMS service account${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT \
  --role roles/pubsub.publisher
echo ""

# Grant Eventarc Event Receiver role to the Compute Engine default service account
echo "${BLUE_TEXT}${BOLD_TEXT}---> Granting Eventarc Event Receiver role to the Compute Engine default service account${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
  --role roles/eventarc.eventReceiver
echo ""

# Export the current IAM policy to a file
echo "${BLUE_TEXT}${BOLD_TEXT}---> Exporting current IAM policy to policy.yaml${RESET_FORMAT}"
gcloud projects get-iam-policy $DEVSHELL_PROJECT_ID > policy.yaml
echo ""

# Append audit logging configuration to the IAM policy
echo "${BLUE_TEXT}${BOLD_TEXT}---> Appending audit logging configuration to policy.yaml${RESET_FORMAT}"
cat <<EOF >> policy.yaml
auditConfigs:
- auditLogConfigs:
  - logType: ADMIN_READ
  - logType: DATA_READ
  - logType: DATA_WRITE
  service: compute.googleapis.com
EOF
echo ""

# Set the updated IAM policy
echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting the updated IAM policy from policy.yaml${RESET_FORMAT}"
gcloud projects set-iam-policy $DEVSHELL_PROJECT_ID policy.yaml
echo ""

# Create and navigate to the hello-http directory
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating and navigating to the hello-http directory${RESET_FORMAT}"
mkdir ~/hello-http && cd $_
echo ""

# Create the index.js file with the Cloud Function code
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating index.js with Cloud Function code${RESET_FORMAT}"
cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');

functions.http('helloWorld', (req, res) => {
  res.status(200).send('HTTP with Node.js in GCF 2nd gen!');
});
EOF
echo ""

# Create the package.json file with dependencies
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating package.json with dependencies${RESET_FORMAT}"
cat > package.json <<EOF
{
  "name": "nodejs-functions-gen2-codelab",
  "version": "0.0.1",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^2.0.0"
  }
}
EOF
echo ""

# Define a function to deploy the Cloud Function with retry logic
echo "${BLUE_TEXT}${BOLD_TEXT}---> Defining deploy_function with retry logic${RESET_FORMAT}"
deploy_function() {
  while true; do
    echo "Attempting to deploy the Cloud Function..."
    
    gcloud functions deploy nodejs-http-function \
      --gen2 \
      --runtime nodejs22 \
      --entry-point helloWorld \
      --source . \
      --region $REGION \
      --trigger-http \
      --timeout 600s \
      --max-instances 1 \
      --allow-unauthenticated
    
    if [ $? -eq 0 ]; then
      echo "Cloud Function deployed successfully!"
      break
    else
      echo "Deployment failed. Retrying in 30 seconds..."
      sleep 30
    fi
  done
}
echo ""

# Call the deploy_function to deploy the Cloud Function
echo "${BLUE_TEXT}${BOLD_TEXT}---> Deploying the Cloud Function using deploy_function${RESET_FORMAT}"
deploy_function
echo ""

# Call the deployed Cloud Function
echo "${BLUE_TEXT}${BOLD_TEXT}---> Calling the deployed Cloud Function${RESET_FORMAT}"
gcloud functions call nodejs-http-function \
  --gen2 --region $REGION
echo ""

# Create and navigate to the hello-storage directory
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating and navigating to the hello-storage directory${RESET_FORMAT}"
mkdir ~/hello-storage && cd $_
echo ""

# Create the index.js file for the Cloud Storage-triggered function
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating index.js for Cloud Storage-triggered function${RESET_FORMAT}"
cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');

functions.cloudEvent('helloStorage', (cloudevent) => {
  console.log('Cloud Storage event with Node.js in GCF 2nd gen!');
  console.log(cloudevent);
});
EOF
echo ""

# Create the package.json file with dependencies
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating package.json with dependencies${RESET_FORMAT}"
cat > package.json <<EOF
{
  "name": "nodejs-functions-gen2-codelab",
  "version": "0.0.1",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^2.0.0"
  }
}
EOF
echo ""

# Create a Cloud Storage bucket
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a Cloud Storage bucket${RESET_FORMAT}"
BUCKET="gs://gcf-gen2-storage-$PROJECT_ID"
gsutil mb -l $REGION $BUCKET
echo ""

# Define a function to deploy the Cloud Storage-triggered function with retry logic
echo "${BLUE_TEXT}${BOLD_TEXT}---> Defining deploy_function for Cloud Storage-triggered function${RESET_FORMAT}"
deploy_function() {
  while true; do
    echo "Attempting to deploy the Cloud Function..."
    
    gcloud functions deploy nodejs-storage-function \
      --gen2 \
      --runtime nodejs22 \
      --entry-point helloStorage \
      --source . \
      --region $REGION \
      --trigger-bucket $BUCKET \
      --trigger-location $REGION \
      --max-instances 1
    
    if [ $? -eq 0 ]; then
      echo "Cloud Function deployed successfully!"
      break
    else
      echo "Deployment failed. Retrying in 30 seconds..."
      sleep 30
    fi
  done
}
echo ""

# Call the deploy_function to deploy the Cloud Storage-triggered function
echo "${BLUE_TEXT}${BOLD_TEXT}---> Deploying the Cloud Storage-triggered function using deploy_function${RESET_FORMAT}"
deploy_function
echo ""

# Upload a file to trigger the Cloud Function
echo "${BLUE_TEXT}${BOLD_TEXT}---> Uploading a file to trigger the Cloud Function${RESET_FORMAT}"
echo "Hello World" > random.txt
gsutil cp random.txt $BUCKET/random.txt
echo ""

# Read logs from the Cloud Function
echo "${BLUE_TEXT}${BOLD_TEXT}---> Reading logs from the Cloud Function${RESET_FORMAT}"
gcloud functions logs read nodejs-storage-function \
  --region $REGION --gen2 --limit=100 --format "value(log)"
echo ""

# Clone the eventarc-samples repository
echo "${BLUE_TEXT}${BOLD_TEXT}---> Cloning the eventarc-samples repository${RESET_FORMAT}"
cd ~
git clone https://github.com/GoogleCloudPlatform/eventarc-samples.git
echo ""

# Navigate to the gce-vm-labeler directory
echo "${BLUE_TEXT}${BOLD_TEXT}---> Navigating to the gce-vm-labeler directory${RESET_FORMAT}"
cd ~/eventarc-samples/gce-vm-labeler/gcf/nodejs
echo ""

# Define a function to deploy the VM labeler function with retry logic
echo "${BLUE_TEXT}${BOLD_TEXT}---> Defining deploy_function for VM labeler function${RESET_FORMAT}"
deploy_function() {
  while true; do
    echo "Attempting to deploy the Cloud Function..."
    
    gcloud functions deploy gce-vm-labeler \
      --gen2 \
      --runtime nodejs22 \
      --entry-point labelVmCreation \
      --source . \
      --region $REGION \
     
    if [ $? -eq 0 ]; then
      echo "${GREEN_TEXT}${BOLD_TEXT}Cloud Function deployed successfully.${RESET_FORMAT}"
      break
    else
      echo "${RED_TEXT}${BOLD_TEXT}Error deploying Cloud Function. Retrying...${RESET_FORMAT}"
      sleep 10  # Retry after 10 seconds
    fi
  done
}

# Now, let's deploy the Cloud Function
deploy_function

# Optionally, you can verify the deployment status
echo "${BLUE_TEXT}${BOLD_TEXT}---> Verifying the Cloud Function deployment${RESET_FORMAT}"
gcloud functions describe gce-vm-labeler --region $REGION

# If necessary, you can test the function by invoking it manually
echo "${BLUE_TEXT}${BOLD_TEXT}---> Testing the deployed Cloud Function${RESET_FORMAT}"
gcloud functions call gce-vm-labeler --region $REGION --data '{"vmName": "test-vm"}'

# Output success message
echo "${GREEN_TEXT}${BOLD_TEXT}VM Labeler Function deployment and test complete.${RESET_FORMAT}"

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
