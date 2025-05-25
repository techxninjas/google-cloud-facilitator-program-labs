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
echo "${CYAN_TEXT}${BOLD_TEXT}                 Dataflow: Qwik Start - Templates               ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-----------------------------------------------------------------------${RESET_FORMAT}"
echo ""

# Author: Aadil Latif
# Script: TechX Ninjas Lab Setup
# Version: 1.0

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
echo "${BLUE_TEXT}${BOLD_TEXT}---> Disabling Dataflow API...${RESET_FORMAT}"
echo

gcloud services disable dataflow.googleapis.com

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling Dataflow API...${RESET_FORMAT}"
echo
gcloud services enable dataflow.googleapis.com

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating BigQuery Dataset...${RESET_FORMAT}"
echo

bq mk taxirides

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating BigQuery Table...${RESET_FORMAT}"
echo

bq mk \
--time_partitioning_field timestamp \
--schema ride_id:string,point_idx:integer,latitude:float,longitude:float,\
timestamp:timestamp,meter_reading:float,meter_increment:float,ride_status:string,\
passenger_count:integer -t taxirides.realtime

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating GCS Bucket...${RESET_FORMAT}"
echo

gsutil mb gs://$DEVSHELL_PROJECT_ID/

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Waiting for 45 seconds to finish GCS creation...${RESET_FORMAT}"
echo

sleep 45

check_job_status() {
    while true; do
        JOB_STATUS=$(gcloud dataflow jobs list --region "$REGION" --filter="name=iotflow" --format="value(state)")
        
        if [[ "$JOB_STATUS" == "Running" ]]; then
            echo "${GREEN_TEXT}${BOLD_TEXT} Dataflow job is running successfully! ${RESET_FORMAT}"
            return 0
        elif [[ "$JOB_STATUS" == "Failed" || "$JOB_STATUS" == "Cancelled" ]]; then
            echo "${RED_TEXT}${BOLD_TEXT} Dataflow job failed! Retrying... ${RESET_FORMAT}"
            return 1
        fi
        
        echo "Waiting for job to complete..."
        sleep 20
    done
}

# Function to run Dataflow job
run_dataflow_job() {
    echo
    echo "${BLUE_TEXT}${BOLD_TEXT}---> Running Dataflow Job...${RESET_FORMAT}"
    echo

    JOB_ID=$(gcloud dataflow jobs run iotflow \
    --gcs-location gs://dataflow-templates/latest/PubSub_to_BigQuery \
    --region "$REGION" \
    --staging-location gs://$DEVSHELL_PROJECT_ID/temp \
    --parameters inputTopic=projects/pubsub-public-data/topics/taxirides-realtime,outputTableSpec=$DEVSHELL_PROJECT_ID:taxirides.realtime \
    --format="value(id)")

    echo "Dataflow Job ID: $JOB_ID"
    sleep 30  # Give it some time to start
}

# Run job and check status in a loop
while true; do
    run_dataflow_job
    check_job_status

    if [[ $? -eq 0 ]]; then
        break
    else
        echo "${YELLOW_TEXT}${BOLD_TEXT} Deleting failed Dataflow job... ${RESET_FORMAT}"
        gcloud dataflow jobs cancel iotflow --region "$REGION"
        echo "${YELLOW_TEXT}${BOLD_TEXT} Retrying Dataflow job... ${RESET_FORMAT}"
        sleep 10
    fi
done
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

shopt -s nullglob
for file in gsp* arc* shell*; do
    [[ -f "$file" ]] && rm "$file" && echo "Removed: $file"
done
shopt -u nullglob
echo

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
