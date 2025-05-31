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
echo "${CYAN_TEXT}${BOLD_TEXT}                 Fundamentals of Cloud Logging                 ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}----------------------------------------------------------------${RESET_FORMAT}"
echo ""

# 🌍 Fetching Region
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔄 Fetching Location...${RESET_FORMAT}"
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

echo "${BLUE_TEXT}${BOLD_TEXT}Creating a logging metric named '200responses' to count successful App Engine responses... ${RESET_FORMAT}"
gcloud logging metrics create 200responses \
  --description="Counts 200 OK responses from the default App Engine service" \
  --log-filter='resource.type="gae_app" AND resource.labels.module_id="default" AND (protoPayload.status=200 OR httpRequest.status=200)'

echo
echo "${BLUE_TEXT}${BOLD_TEXT}Generating the configuration file 'latency_metric.yaml' for a latency distribution metric... ${RESET_FORMAT}"
cat > latency_metric.yaml <<EOF
name: projects/\$PROJECT_ID/metrics/latency_metric
description: "latency distribution"
filter: >
  resource.type="gae_app"
  resource.labels.module_id="default"
  (protoPayload.status=200 OR httpRequest.status=200)
  logName=("projects/\$PROJECT_ID/logs/cloudbuild" OR
           "projects/\$PROJECT_ID/logs/stderr" OR
           "projects/\$PROJECT_ID/logs/%2Fvar%2Flog%2Fgoogle_init.log" OR
           "projects/\$PROJECT_ID/logs/appengine.googleapis.com%2Frequest_log" OR
           "projects/\$PROJECT_ID/logs/cloudaudit.googleapis.com%2Factivity")
  severity>=DEFAULT
valueExtractor: EXTRACT(protoPayload.latency)
metricDescriptor:
  metricKind: DELTA
  valueType: DISTRIBUTION
  unit: "s"
  displayName: "Latency distribution"
bucketOptions:
  exponentialBuckets:
    numFiniteBuckets: 10
    growthFactor: 2.0
    scale: 0.01
EOF

echo "${BLUE_TEXT}${BOLD_TEXT}Creating the 'latency_metric' using the configuration from 'latency_metric.yaml'... ${RESET_FORMAT}"
gcloud logging metrics create latency_metric --config-from-file=latency_metric.yaml
echo

echo "${MAGENTA_TEXT}${BOLD_TEXT}Creating a new Compute Engine VM instance named 'audit-log-vm'. This may take a few moments... ${RESET_FORMAT}"
gcloud compute instances create audit-log-vm \
  --zone=$ZONE \
  --machine-type=e2-micro \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --tags=http-server \
  --metadata=startup-script='#!/bin/bash
    sudo apt update && sudo apt install -y apache2
    sudo systemctl start apache2' \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --labels=env=lab \
  --quiet

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Setting up an Audit Log Sink to export logs to BigQuery. ${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}Confirming the current GCP Project ID for sink configuration... ${RESET_FORMAT}"
PROJECT_ID=$(gcloud config get-value project)
SINK_NAME="AuditLogs"
BQ_DATASET="AuditLogs"
BQ_LOCATION="US"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Ensuring the BigQuery dataset '$BQ_DATASET' exists in location '$BQ_LOCATION'... ${RESET_FORMAT}"
bq --location=$BQ_LOCATION mk --dataset $PROJECT_ID:$BQ_DATASET

echo "${CYAN_TEXT}${BOLD_TEXT}Creating the logging sink '$SINK_NAME' to channel GCE audit logs to the '$BQ_DATASET' BigQuery dataset... ${RESET_FORMAT}"
gcloud logging sinks create $SINK_NAME \
  bigquery.googleapis.com/projects/$PROJECT_ID/datasets/$BQ_DATASET \
  --log-filter='resource.type="gce_instance"
logName="projects/'$PROJECT_ID'/logs/cloudaudit.googleapis.com%2Factivity"' \
  --description="Export GCE audit logs to BigQuery" \
  --project=$PROJECT_ID
echo

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}========================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}            NOW FOLLOW THE VIDEO STEPS FOR NEXT TASKS...      ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}              VIDEO LINK: https://youtu.be/wFTgqoikllg      ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}========================================================${RESET_FORMAT}"
echo

echo "${CYAN_TEXT}${BOLD_TEXT}🔗 OPEN THIS LINK:${RESET_FORMAT} ${BLUE_TEXT}https://console.cloud.google.com/appengine?project=${PROJECT_ID}${RESET_FORMAT}"
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
