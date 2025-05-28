
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
echo "${CYAN_TEXT}${BOLD_TEXT}         LAB_NAME       ${RESET_FORMAT}"
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

echo "${MAGENTA_TEXT}${BOLD_TEXT}===> Please enter the desired metric name:${RESET_FORMAT}"
read METRIC
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}===> Please enter the threshold value for the alert:${RESET_FORMAT}"
read VALUE

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling the Cloud Monitoring API...${RESET_FORMAT}"
gcloud services enable monitoring.googleapis.com
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Cloud Monitoring API enabled successfully.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching the instance ID for 'video-queue-monitor'...${RESET_FORMAT}"
export INSTANCE_ID=$(gcloud compute instances describe video-queue-monitor --project="$DEVSHELL_PROJECT_ID" --zone="$ZONE" --format="get(id)")
echo "${GREEN_TEXT}${BOLD_TEXT}Instance ID fetched: ${INSTANCE_ID}${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Stopping the 'video-queue-monitor' instance temporarily...${RESET_FORMAT}"
gcloud compute instances stop video-queue-monitor --zone $ZONE
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Instance 'video-queue-monitor' stopped.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the startup script (startup-script.sh)...${RESET_FORMAT}"
cat > startup-script.sh <<EOF_START
#!/bin/bash

export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

sudo apt update && sudo apt -y
sudo apt-get install wget -y
sudo apt-get -y install git
sudo chmod 777 /usr/local/
sudo wget https://go.dev/dl/go1.22.8.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.22.8.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
sudo service google-cloud-ops-agent start

mkdir /work
mkdir /work/go
mkdir /work/go/cache
export GOPATH=/work/go
export GOCACHE=/work/go/cache

cd /work/go
mkdir video
gsutil cp gs://spls/gsp338/video_queue/main.go /work/go/video/main.go

go get go.opencensus.io
go get contrib.go.opencensus.io/exporter/stackdriver

export MY_PROJECT_ID=$DEVSHELL_PROJECT_ID
export MY_GCE_INSTANCE_ID=$INSTANCE_ID
export MY_GCE_INSTANCE_ZONE=$ZONE

cd /work
go mod init go/video/main
go mod tidy
go run /work/go/video/main.go
EOF_START
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Startup script created successfully.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Adding the startup script metadata to 'video-queue-monitor'...${RESET_FORMAT}"
gcloud compute instances add-metadata video-queue-monitor \
  --zone $ZONE \
  --metadata-from-file startup-script=startup-script.sh
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Metadata added successfully.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Starting the 'video-queue-monitor' instance...${RESET_FORMAT}"
gcloud compute instances start video-queue-monitor --zone $ZONE
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Instance 'video-queue-monitor' started. The startup script will now execute.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a logs-based metric named '${METRIC}'...${RESET_FORMAT}"
gcloud logging metrics create $METRIC \
    --description="Metric for high resolution video uploads" \
    --log-filter='textPayload=("file_format=4K" OR "file_format=8K")'
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Logs-based metric '${METRIC}' created.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the email notification channel configuration file (email-channel.json)...${RESET_FORMAT}"
cat > email-channel.json <<EOF_END
{
  "type": "email",
  "displayName": "techxninjas",
  "description": "subscribe",
  "labels": {
    "email_address": "$USER_EMAIL"
  }
}
EOF_END
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Email channel configuration file created.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the email notification channel in Cloud Monitoring...${RESET_FORMAT}"
gcloud beta monitoring channels create --channel-content-from-file="email-channel.json"
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Email notification channel created. ${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Retrieving the ID of the newly created email notification channel...${RESET_FORMAT}"
email_channel_info=$(gcloud beta monitoring channels list)
email_channel_id=$(echo "$email_channel_info" | grep -oP 'name: \K[^ ]+' | head -n 1)
echo "${GREEN_TEXT}${BOLD_TEXT}Email channel ID retrieved: ${email_channel_id}${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the alert policy configuration file (techxninjas.json)...${RESET_FORMAT}"
cat > techxninjas.json <<EOF_END
{
  "displayName": "techxninjas",
  "userLabels": {},
  "conditions": [
    {
      "displayName": "VM Instance - logging/user/large_video_upload_rate",
      "conditionThreshold": {
        "filter": "resource.type = \"gce_instance\" AND metric.type = \"logging.googleapis.com/user/$METRIC\"",
        "aggregations": [
          {
            "alignmentPeriod": "300s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "0s",
        "trigger": {
          "count": 1
        },
        "thresholdValue": $VALUE
      }
    }
  ],
  "alertStrategy": {
    "notificationPrompts": [
      "OPENED"
    ]
  },
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [
    "$email_channel_id"
  ],
  "severity": "SEVERITY_UNSPECIFIED"
}
EOF_END
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Alert policy configuration file created.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the alert policy in Cloud Monitoring...${RESET_FORMAT}"
gcloud alpha monitoring policies create --policy-from-file=techxninjas.json
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Alert policy created successfully.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Monitoring Dashboard Link:${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}https://console.cloud.google.com/monitoring/dashboards?project=$DEVSHELL_PROJECT_ID${RESET_FORMAT}"
echo

echo "${CYAN_TEXT}${BOLD_TEXT}---> Expected Metrics: input_queue_size, ${METRIC}${RESET_FORMAT}"
echo

echo
echo "${BLUE_TEXT}${BOLD_TEXT}================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}     NOW SEE THE VIDEO CAREFULLY FOR ALL TASKS    ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}================================================${RESET_FORMAT}"
echo

sleep 30

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
