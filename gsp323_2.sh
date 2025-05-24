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
echo "${CYAN_TEXT}${BOLD_TEXT}         Prepare Data for ML APIs on Google Cloud: Challenge Lab       ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-----------------------------------------------------------------------${RESET_FORMAT}"
echo ""

# 💡 Start-Up Banner
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         🚀 INITIATING THE 2nd PART TASK EXECUTION...          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo ""

# Step 34: Authenticate to Google Cloud without launching a browser
echo "${BLUE_TEXT}${BOLD_TEXT}---> Authenticating to Google Cloud...${RESET_FORMAT}"
echo
gcloud auth login --no-launch-browser --quiet
echo ""

sleep 10

echo "${BLUE_TEXT}${BOLD_TEXT}---> Retrieving project ID...${RESET}"
DEVSHELL_PROJECT_ID=$(gcloud config get-value project)
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Retrieving project number...${RESET}"
PROJECT_NUMBER=$(gcloud projects describe "$DEVSHELL_PROJECT_ID" --format="json" | jq -r '.projectNumber')
echo ""

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")
echo ""

# Step 35: Create a new Dataproc cluster
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Dataproc cluster...${RESET_FORMAT}"
gcloud dataproc clusters create awesome --enable-component-gateway --region $REGION --master-machine-type e2-standard-2 --master-boot-disk-type pd-balanced --master-boot-disk-size 100 --num-workers 2 --worker-machine-type e2-standard-2 --worker-boot-disk-type pd-balanced --worker-boot-disk-size 100 --image-version 2.2-debian12 --project $DEVSHELL_PROJECT_ID
echo ""

# Step 36: Get the VM instance name from the project
echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching VM instance name...${RESET_FORMAT}"
VM_NAME=$(gcloud compute instances list --project="$DEVSHELL_PROJECT_ID" --format=json | jq -r '.[0].name')
echo ""

# Step 37: Get the compute zone of the VM
echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching VM zone...${RESET_FORMAT}"
export ZONE=$(gcloud compute instances list $VM_NAME --format 'csv[no-heading](zone)')
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying data to HDFS on VM...${RESET_FORMAT}"
gcloud compute ssh --zone "$ZONE" "$VM_NAME" --project "$DEVSHELL_PROJECT_ID" --quiet --command="hdfs dfs -cp gs://cloud-training/gsp323/data.txt /data.txt"
echo ""

# Step 39: Copy data from Cloud Storage to local storage in the VM
echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying data to local storage on VM...${RESET_FORMAT}"
gcloud compute ssh --zone "$ZONE" "$VM_NAME" --project "$DEVSHELL_PROJECT_ID" --quiet --command="gsutil cp gs://cloud-training/gsp323/data.txt /data.txt"
echo ""

# Step 40: Submit a Spark job to the Dataproc cluster
echo "${BLUE_TEXT}${BOLD_TEXT}---> Submitting Spark job to Dataproc...${RESET_FORMAT}"
gcloud dataproc jobs submit spark \
  --cluster=awesome \
  --region=$REGION \
  --class=org.apache.spark.examples.SparkPageRank \
  --jars=file:///usr/lib/spark/examples/jars/spark-examples.jar \
  --project=$DEVSHELL_PROJECT_ID \
  -- /data.txt
echo ""

cd

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
