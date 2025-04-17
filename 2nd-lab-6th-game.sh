#!/bin/bash
# Define color variables

BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

# 💡 Start-Up Banner 
echo -e "${BRIGHT_PURPLE}${BOLD}--------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}       6th Game: Lab 2nd           ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}--------------------------------------${RESET}"
echo ""

# 🚀 Task Execution Init
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}         🚀 INITIATING THE TASK EXECUTION...           ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

echo -n "${YELLOW_TEXT}${BOLD_TEXT}Enter the location (Check your Lab and type the Location here): ${RESET_FORMAT}"
read REGION
export REGION
export PROJECT_ID=`gcloud config get-value project`
export DATASET_ID=dataset1
export FHIR_STORE_ID=fhirstore1
export DICOM_STORE_ID=dicomstore1
export HL7_STORE_ID=hl7v2store1

gcloud services enable compute.googleapis.com container.googleapis.com dataflow.googleapis.com bigquery.googleapis.com pubsub.googleapis.com healthcare.googleapis.com

gcloud healthcare datasets create dataset1 --location=${REGION}

sleep 30

PROJECT_NUMBER=$(gcloud projects describe $DEVSHELL_PROJECT_ID --format="value(projectNumber)")

SERVICE_ACCOUNT="service-${PROJECT_NUMBER}@gcp-sa-healthcare.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_NUMBER \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/bigquery.admin"

gcloud projects add-iam-policy-binding $PROJECT_NUMBER \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/storage.objectAdmin"

gcloud projects add-iam-policy-binding $PROJECT_NUMBER \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/healthcare.datasetAdmin"

gcloud projects add-iam-policy-binding $PROJECT_NUMBER \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/pubsub.publisher"

gcloud pubsub topics create projects/$PROJECT_ID/topics/hl7topic

gcloud pubsub subscriptions create hl7_subscription --topic=hl7topic

gcloud healthcare hl7v2-stores create $HL7_STORE_ID --dataset=$DATASET_ID --location=$REGION --notification-config=pubsub-topic=projects/$PROJECT_ID/topics/hl7topic

# ✅ Completion Message
echo "${BRIGHT_GREEN}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${BRIGHT_GREEN}${BOLD}             ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!         ${RESET_FORMAT}"
echo "${BRIGHT_GREEN}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA
echo -e "${BRIGHT_YELLOW}${BOLD}🔔 Follow for more labs & tutorials:${RESET}"
echo -e "${BRIGHT_RED}${BOLD}YouTube Channel:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}Follow me on LinkedIn:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.linkedin.com/in/iaadillatif${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}LinkedIn Page:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.linkedin.com/company/techxninjas${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}Join WhatsApp Group:${RESET} ${BRIGHT_GREEN}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET}"
echo ""
