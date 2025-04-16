#!/bin/bash

# 🌈 Define Color Variables
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

RESET_FORMAT=$'\033[0m'
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'

# 🚀 Clear Screen
clear

# 🚨 Welcome Message
echo "${CYAN_TEXT}${BOLD}🚀===========================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}        🧠 5th Lab: Monitor Apache Web Server (Level 2)       ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}     🎯 Game: Cloud Infrastructure & API Essentials           ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}===========================================================🚀${RESET_FORMAT}"
echo ""

# 🌍 Input Zone
read -p "${YELLOW_TEXT}${BOLD}🔧 Enter your Compute Zone:${RESET_FORMAT} " ZONE

# 🔑 Authenticate & Setup Project
echo "${BLUE_TEXT}${BOLD}🔐 Authenticating with Google Cloud...${RESET_FORMAT}"
gcloud auth list

echo "${MAGENTA_TEXT}${BOLD}📁 Fetching Project ID...${RESET_FORMAT}"
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_ID=$DEVSHELL_PROJECT_ID

echo "${GREEN_TEXT}${BOLD}📍 Setting Compute Zone: $ZONE ${RESET_FORMAT}"
gcloud config set compute/zone $ZONE

# 🛠️ Create VM & Configure Firewall
echo "${CYAN_TEXT}${BOLD}Starting Task 1. Creating a Compute Engine VM instance...${RESET_FORMAT}"
gcloud compute instances create quickstart-vm --project=$PROJECT_ID --zone=$ZONE --machine-type=e2-small --image-family=debian-11 --image-project=debian-cloud --tags=http-server,https-server && \
gcloud compute firewall-rules create default-allow-http --target-tags=http-server --allow tcp:80 --description="Allow HTTP traffic" && \
gcloud compute firewall-rules create default-allow-https --target-tags=https-server --allow tcp:443 --description="Allow HTTPS traffic"

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}               ✅ TASK 1 COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your Task 1 progress."
sleep 10

echo "${CYAN_TEXT}${BOLD}Starting Task 2. Install an Apache Web Server...${RESET_FORMAT}"
# 📦 Create Apache + Ops Agent Configuration Script
echo "${YELLOW_TEXT}${BOLD}📜 Preparing configuration script...${RESET_FORMAT}"
cat > cp_disk.sh <<'EOF'
sudo apt-get update && sudo apt-get install apache2 php -y

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}               ✅ TASK 2 COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your Task 2 progress."
sleep 10

echo "${CYAN_TEXT}${BOLD}Starting Task 3. Install and configure the Ops Agent...${RESET_FORMAT}"
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

sudo cp /etc/google-cloud-ops-agent/config.yaml /etc/google-cloud-ops-agent/config.yaml.bak

sudo tee /etc/google-cloud-ops-agent/config.yaml > /dev/null << EOL
metrics:
  receivers:
    apache:
      type: apache
  service:
    pipelines:
      apache:
        receivers:
          - apache
logging:
  receivers:
    apache_access:
      type: apache_access
    apache_error:
      type: apache_error
  service:
    pipelines:
      apache:
        receivers:
          - apache_access
          - apache_error
EOL

sudo service google-cloud-ops-agent restart
sleep 60
EOF

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}               ✅ TASK 3 COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your Task 3 progress."
sleep 10

# 📤 Transfer Script to VM
echo "${CYAN_TEXT}${BOLD}Starting Task 4. Generate traffic and view metrics...${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD}🚚 Copying script to VM...${RESET_FORMAT}"
gcloud compute scp cp_disk.sh quickstart-vm:/tmp --zone=$ZONE --quiet

# 🚀 Execute Script on VM
echo "${CYAN_TEXT}${BOLD}💻 Running setup script on VM...${RESET_FORMAT}"
gcloud compute ssh quickstart-vm --zone=$ZONE --quiet --command="bash /tmp/cp_disk.sh"

# 📡 Setup Notification Channel
echo "${CYAN_TEXT}${BOLD}Starting Task 5. Create an alerting policys...${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD}🔔 Setting up monitoring notification channel...${RESET_FORMAT}"
cat > cp-channel.json <<EOF
{
  "type": "pubsub",
  "displayName": "arcadecrew",
  "description": "subscribe to arcadecrew",
  "labels": {
    "topic": "projects/$PROJECT_ID/topics/notificationTopic"
  }
}
EOF

gcloud beta monitoring channels create --channel-content-from-file=cp-channel.json

# 🧾 Fetch Channel ID
echo "${GREEN_TEXT}${BOLD}🔍 Fetching notification channel ID...${RESET_FORMAT}"
email_channel=$(gcloud beta monitoring channels list)
channel_id=$(echo "$email_channel" | grep -oP 'name: \K[^ ]+' | head -n 1)

# 🛎️ Create Alert Policy
echo "${YELLOW_TEXT}${BOLD}📈 Creating alert policy for Apache traffic...${RESET_FORMAT}"
cat > stopped-vm-alert-policy.json <<EOF
{
  "displayName": "Apache traffic above threshold",
  "conditions": [
    {
      "displayName": "VM Instance - workload/apache.traffic",
      "conditionThreshold": {
        "filter": "resource.type = \"gce_instance\" AND metric.type = \"workload.googleapis.com/apache.traffic\"",
        "aggregations": [
          {
            "alignmentPeriod": "60s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "0s",
        "trigger": {
          "count": 1
        },
        "thresholdValue": 4000
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
EOF

gcloud alpha monitoring policies create --policy-from-file=stopped-vm-alert-policy.json

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}               ✅ TASK 5 COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your Task 5 progress."
sleep 10

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
