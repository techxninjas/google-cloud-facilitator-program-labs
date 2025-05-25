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
echo "${CYAN_TEXT}${BOLD_TEXT}               Monitoring in Google Cloud: Challenge Lab         ${RESET_FORMAT}"
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
DEVSHELL_PROJECT_ID=`gcloud config get-value project`
echo ""

# 🔢 Fetching Project Number
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔍 Fetching Project Number...${RESET_FORMAT}"
export PROJECT_NUMBER=$(gcloud projects describe $DEVSHELL_PROJECT_ID --format="value(projectNumber)")
echo ""
echo ""

# 💡 Start-Up Banner
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         🚀 INITIATING THE TASK EXECUTION...          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo ""

# Informing user about the zone retrieval
echo "${BLUE_TEXT}${BOLD_TEXT}---> Retrieving the compute instance zone...${RESET_FORMAT}"
export ZONE=$(gcloud compute instances list --project=$DEVSHELL_PROJECT_ID --format='value(ZONE)' | head -n 1)
echo "${GREEN_TEXT}Zone Retrieved: ${BOLD_TEXT}$ZONE${RESET_FORMAT}"
echo

# Informing user about the instance ID retrieval
echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching the instance ID of apache-vm...${RESET_FORMAT}"
INSTANCE_ID=$(gcloud compute instances describe apache-vm --zone=$ZONE --format='value(id)')
echo "${GREEN_TEXT}Instance ID: ${BOLD_TEXT}$INSTANCE_ID${RESET_FORMAT}"
echo

cat > cp_disk.sh <<'EOF_CP'
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
sudo bash add-logging-agent-repo.sh --also-install

curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh
sudo bash add-monitoring-agent-repo.sh --also-install

(cd /etc/stackdriver/collectd.d/ && sudo curl -O https://raw.githubusercontent.com/Stackdriver/stackdriver-agent-service-configs/master/etc/collectd.d/apache.conf)

sudo service stackdriver-agent restart
EOF_CP

echo "${BLUE_TEXT}${BOLD_TEXT}---> Transferring script to apache-vm...${RESET_FORMAT}"
gcloud compute scp cp_disk.sh apache-vm:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet
echo "${GREEN_TEXT}Script transferred successfully.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing script on apache-vm...${RESET_FORMAT}"
gcloud compute ssh apache-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/cp_disk.sh"
echo "${GREEN_TEXT}Script execution completed.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating uptime check for the instance...${RESET_FORMAT}"
gcloud monitoring uptime create techxninjas \
  --resource-type="gce-instance" \
  --resource-labels=project_id=$DEVSHELL_PROJECT_ID,instance_id=$INSTANCE_ID,zone=$ZONE
echo "${GREEN_TEXT}Uptime check created successfully.${RESET_FORMAT}"
echo

cat > email-channel.json <<EOF_CP
{
  "type": "email",
  "displayName": "TechXNinjas",
  "description": "techxninjas",
  "labels": {
    "email_address": "$USER_EMAIL"
  }
}
EOF_CP

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating email notification channel...${RESET_FORMAT}"
gcloud beta monitoring channels create --channel-content-from-file="email-channel.json"
echo "${GREEN_TEXT}Notification channel created.${RESET_FORMAT}"
echo

channel_info=$(gcloud beta monitoring channels list)
channel_id=$(echo "$channel_info" | grep -oP 'name: \K[^ ]+' | head -n 1)

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating alert policy...${RESET_FORMAT}"
cat > app-engine-error-percent-policy.json <<EOF_CP
{
  "displayName": "alert",
  "userLabels": {},
  "conditions": [
    {
      "displayName": "VM Instance - Traffic",
      "conditionThreshold": {
        "filter": "resource.type = \"gce_instance\" AND metric.type = \"agent.googleapis.com/apache/traffic\"",
        "aggregations": [
          {
            "alignmentPeriod": "60s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "300s",
        "trigger": {
          "count": 1
        },
        "thresholdValue": 3072
      }
    }
  ],
  "alertStrategy": {
    "autoClose": "1800s"
  },
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [
    "$channel_id"
  ],
  "severity": "SEVERITY_UNSPECIFIED"
}
EOF_CP

gcloud alpha monitoring policies create --policy-from-file="app-engine-error-percent-policy.json"
echo "${GREEN_TEXT}Alert policy created successfully.${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}See the Video carefully for doing next Tasks...${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Click this link to open Dashboard for Task 4: ${YELLOW_TEXT}${BOLD_TEXT}https://console.cloud.google.com/monitoring/dashboards?&project=$DEVSHELL_PROJECT_ID${RESET_FORMAT}"
echo
for i in {1..60}; do
    echo -ne "${CYAN_TEXT}⏳ ${i}/60 seconds for doing this Task\r${RESET_FORMAT}"
    sleep 1
done

echo ""
echo "${GREEN_TEXT}${BOLD_TEXT}Click this link to Create Metric for Task 5: ${YELLOW_TEXT}${BOLD_TEXT}https://console.cloud.google.com/logs/metrics/edit?project=$DEVSHELL_PROJECT_ID${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}Configuration for creating a Log-Based Metric:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}resource.type="gce_instance"${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}logName="projects/${PROJECT_ID}/logs/apache-access"${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}textPayload:"200"${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}Configuration for labels:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}Label Name: techxninjas"${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}Field Name: textPayload"${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}Regular Expression: execution took (\\d+)"${RESET_FORMAT}"

for i in {1..60}; do
    echo -ne "${CYAN_TEXT}⏳ ${i}/60 seconds for doing this Task\r${RESET_FORMAT}"
    sleep 1
done
echo ""

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
