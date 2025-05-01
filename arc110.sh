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
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔄 Fetching Location...${RESET_FORMAT}"
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")
echo ""

# 🆔 Fetching Project ID
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔍 Fetching Project ID...${RESET_FORMAT}"
PROJECT_ID=`gcloud config get-value project`
echo ""

# 🔢 Fetching Project Number
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔍 Fetching Project Number...${RESET_FORMAT}"
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
echo ""

echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔍 Fetching Pre-Requisuites...${RESET_FORMAT}"
export BUCKET_NAME="${PROJECT_ID}-bucket"
echo ""

# 💡 Start-Up Banner
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         🚀 INITIATING THE TASK EXECUTION...          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo ""

read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter TOPIC Name of Task 1: ${RESET_FORMAT}" TOPIC_ID
export TOPIC_ID=$TOPIC_ID
echo "${GREEN_TEXT}${BOLD_TEXT}You entered TOPIC: ${RESET_FORMAT}${TOPIC_ID}"
echo 

read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter MESSAGE of Task 2: ${RESET_FORMAT}" MESSAGE
export MESSAGE=$MESSAGE
echo "${GREEN_TEXT}${BOLD_TEXT}You entered MESSAGE: ${RESET_FORMAT}${MESSAGE}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Disabling Dataflow API if already enabled...${RESET_FORMAT}"
gcloud services disable dataflow.googleapis.com
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling required APIs: Dataflow and Cloud Scheduler...${RESET_FORMAT}"
gcloud services enable dataflow.googleapis.com
gcloud services enable cloudscheduler.googleapis.com
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a Cloud Storage bucket: ${RESET_FORMAT}gs://${BUCKET_NAME}"
gsutil mb gs://$BUCKET_NAME
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Pub/Sub topic: ${RESET_FORMAT}${TOPIC_ID}"
gcloud pubsub topics create $TOPIC_ID
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating App Engine application in region: ${RESET_FORMAT}${REGION}"
gcloud app create --region=$REGION
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}---> ---> Waiting 2 mins for App Engine setup to complete...${RESET_FORMAT}"
for i in {1..120}; do
    echo -ne "${CYAN_TEXT}⏳ ${i}/120 seconds elapsed\r${RESET_FORMAT}"
    sleep 1
done
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a Cloud Scheduler job to publish messages to the topic...${RESET_FORMAT}"
gcloud scheduler jobs create pubsub pubsubcreationgsp --schedule="* * * * *" \
  --topic=$TOPIC_ID --message-body="$MESSAGE"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}---> ---> Waiting for the Scheduler job to be ready...${RESET_FORMAT}"
for i in {1..20}; do
    echo -ne "${CYAN_TEXT}⏳ ${i}/20 seconds elapsed\r${RESET_FORMAT}"
    sleep 1
done
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Running the Cloud Scheduler job manually for testing...${RESET_FORMAT}"
gcloud scheduler jobs run pubsubcreationgsp

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a script to run Pub/Sub to GCS pipeline...${RESET_FORMAT}"
cat > pubsub_to_gcs.sh <<EOF_CP
#!/bin/bash

# Clone the repository and navigate to the required directory
git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
cd python-docs-samples/pubsub/streaming-analytics

# Install dependencies
pip install -U -r requirements.txt

# Run the Python script with parameters
python PubSubToGCS.py \
  --project=$PROJECT_ID \
  --region=$REGION \
  --input_topic=projects/$PROJECT_ID/topics/$TOPIC_ID \
  --output_path=gs://$BUCKET_NAME/samples/output \
  --runner=DataflowRunner \
  --window_size=2 \
  --num_shards=2 \
  --temp_location=gs://$BUCKET_NAME/temp
EOF_CP

chmod +x pubsub_to_gcs.sh

echo "${BLUE_TEXT}${BOLD_TEXT}---> Running the Pub/Sub to GCS pipeline script inside a Docker container...${RESET_FORMAT}"
docker run -it \
  -e DEVSHELL_PROJECT_ID=$DEVSHELL_PROJECT_ID \
  -v "$(pwd)/pubsub_to_gcs.sh:/pubsub_to_gcs.sh" \
  python:3.7 \
  /bin/bash -c "/pubsub_to_gcs.sh"

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
