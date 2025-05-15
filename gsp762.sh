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
echo "${CYAN_TEXT}${BOLD_TEXT}            User Authentication: Identity-Aware Proxy                ${RESET_FORMAT}"
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

echo "${YELLOW_TEXT}${BOLD_TEXT}Enabling required Google Cloud services...${RESET_FORMAT}"
gcloud services enable cloudbuild.googleapis.com
gcloud services enable storage-component.googleapis.com
gcloud services enable run.googleapis.com

echo "${YELLOW_TEXT}${BOLD_TEXT}Listing active Google Cloud account...${RESET_FORMAT}"
gcloud auth list --filter=status:ACTIVE --format="value(account)"

echo "${YELLOW_TEXT}${BOLD_TEXT}Cloning the repository...${RESET_FORMAT}"
git clone https://github.com/Deleplace/pet-theory.git

echo "${YELLOW_TEXT}${BOLD_TEXT}Navigating to the lab directory...${RESET_FORMAT}"
cd pet-theory/lab03

echo "${YELLOW_TEXT}${BOLD_TEXT}Downloading the server.go file...${RESET_FORMAT}"
curl -LO https://raw.githubusercontent.com/techxninjas/google-cloud-facilitator-program-labs/refs/heads/main/server.go

echo "${YELLOW_TEXT}${BOLD_TEXT}Building the Go application...${RESET_FORMAT}"
go build -o server

echo "${YELLOW_TEXT}${BOLD_TEXT}Creating the Dockerfile...${RESET_FORMAT}"
cat > Dockerfile <<EOF_END
FROM debian:buster
RUN apt-get update -y \
  && apt-get install -y libreoffice \
  && apt-get clean
WORKDIR /usr/src/app
COPY server .
CMD [ "./server" ]
EOF_END

echo "${YELLOW_TEXT}${BOLD_TEXT}Submitting the Cloud Build job...${RESET_FORMAT}"
gcloud builds submit \
  --tag gcr.io/$PROJECT_ID/pdf-converter

echo "${YELLOW_TEXT}${BOLD_TEXT}Deploying the Cloud Run service...${RESET_FORMAT}"
gcloud run deploy pdf-converter \
  --image gcr.io/$PROJECT_ID/pdf-converter \
  --platform managed \
  --region $REGION \
  --memory=2Gi \
  --no-allow-unauthenticated \
  --set-env-vars PDF_BUCKET=$PROJECT_ID-processed \
  --max-instances=3

echo "${YELLOW_TEXT}${BOLD_TEXT}Creating a Cloud Storage notification...${RESET_FORMAT}"
gsutil notification create -t new-doc -f json -e OBJECT_FINALIZE gs://$PROJECT_ID-upload

echo "${YELLOW_TEXT}${BOLD_TEXT}Creating the Pub/Sub Cloud Run invoker service account...${RESET_FORMAT}"
gcloud iam service-accounts create pubsub-cloud-run-invoker --display-name "PubSub Cloud Run Invoker"

echo "${YELLOW_TEXT}${BOLD_TEXT}Adding IAM policy binding for the Cloud Run service...${RESET_FORMAT}"
gcloud run services add-iam-policy-binding pdf-converter \
  --member=serviceAccount:pubsub-cloud-run-invoker@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/run.invoker \
  --region $REGION \
  --platform managed

echo "${YELLOW_TEXT}${BOLD_TEXT}Adding IAM policy binding for the Pub/Sub service account...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountTokenCreator

echo "${YELLOW_TEXT}${BOLD_TEXT}Retrieving the Cloud Run service URL...${RESET_FORMAT}"
SERVICE_URL=$(gcloud run services describe pdf-converter \
  --platform managed \
  --region $REGION \
  --format "value(status.url)")

echo "${YELLOW_TEXT}${BOLD_TEXT}Creating the Pub/Sub subscription...${RESET_FORMAT}"
gcloud pubsub subscriptions create pdf-conv-sub \
  --topic new-doc \
  --push-endpoint=$SERVICE_URL \
  --push-auth-service-account=pubsub-cloud-run-invoker@$PROJECT_ID.iam.gserviceaccount.com

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}               ✅ ALL TASKS COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your progress."
echo "${GREEN_TEXT}${BOLD_TEXT} If it will be not completed, try again for successfully completion of the Assessment."
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
