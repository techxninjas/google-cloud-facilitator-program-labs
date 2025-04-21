#!/bin/bash

# Bright Foreground Colors
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

# 🚨 Welcome Message
echo "${CYAN_TEXT}${BOLD}🚀===========================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}          1st Lab: Dataflow: Qwik Start - Templates         ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}         Skills Boost Arcade Trivia April 2025 Week 4         ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}===========================================================🚀${RESET_FORMAT}"
echo ""

# 🚀 Task Execution Init
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}         🚀 INITIATING THE TASK EXECUTION...          ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

# Instruction for setting up region and zone
echo "${CYAN_TEXT}${BOLD_TEXT}Setting up default region and zone...${RESET_FORMAT}"
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Disabling Dataflow API...${RESET_FORMAT}"
echo

gcloud services disable dataflow.googleapis.com

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Enabling Dataflow API...${RESET_FORMAT}"
echo
gcloud services enable dataflow.googleapis.com

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Creating BigQuery Dataset...${RESET_FORMAT}"
echo

bq mk taxirides

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Creating BigQuery Table...${RESET_FORMAT}"
echo

bq mk \
--time_partitioning_field timestamp \
--schema ride_id:string,point_idx:integer,latitude:float,longitude:float,\
timestamp:timestamp,meter_reading:float,meter_increment:float,ride_status:string,\
passenger_count:integer -t taxirides.realtime

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Creating GCS Bucket...${RESET_FORMAT}"
echo

gsutil mb gs://$DEVSHELL_PROJECT_ID/

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Waiting for 60 seconds to finish GCS creation...${RESET_FORMAT}"
echo

sleep 60

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
    echo "${GREEN_TEXT}${BOLD_TEXT}Running Dataflow Job...${RESET_FORMAT}"
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
