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
# Get the default compute zone for the current project
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# 🔑 Authenticate & Setup Project
echo "${BLUE_TEXT}${BOLD}🔐 Authenticating with Google Cloud...${RESET_FORMAT}"
gcloud auth list
echo ""

echo "${MAGENTA_TEXT}${BOLD}📁 Fetching Project ID...${RESET_FORMAT}"
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_ID=$DEVSHELL_PROJECT_ID
echo ""

# 🛠️ Create VM & Configure Firewall
echo "${CYAN_TEXT}${BOLD}Starting Task 1. Creating a Compute Engine VM instance...${RESET_FORMAT}"

# Create a new Compute Engine VM with the given specs and tags
gcloud compute instances create quickstart-vm \
  --zone=$ZONE \
  --machine-type=e2-small \
  --tags=http-server,https-server \
  --create-disk=auto-delete=yes,boot=yes,device-name=quickstart-vm,image=projects/debian-cloud/global/images/debian-11-bullseye-v20241009,mode=rw,size=10,type=pd-balanced

# Create a firewall rule to allow HTTP traffic from anywhere
gcloud compute firewall-rules create allow-http-from-internet \
  --target-tags=http-server \
  --allow tcp:80 \
  --source-ranges 0.0.0.0/0 \
  --description="Allow HTTP from the internet"

# Create a firewall rule to allow HTTPS traffic from anywhere
gcloud compute firewall-rules create allow-https-from-internet \
  --target-tags=https-server \
  --allow tcp:443 \
  --source-ranges 0.0.0.0/0 \
  --description="Allow HTTPS from the internet"
echo ""

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}               ✅ TASK 1 COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your Task 1 progress."
echo ""

echo "${CYAN_TEXT}${BOLD}Starting Task 2 & 3. Install an Apache Web Server & configure the Ops Agent......${RESET_FORMAT}"
# 📦 Create Apache + Ops Agent Configuration Script
echo "${YELLOW_TEXT}${BOLD}📜 Preparing configuration script...${RESET_FORMAT}"

# Create a script to prepare the disk (install Apache, PHP, and Ops Agent)
cat > prepare_disk.sh <<'EOF_END'

# Update package lists and install Apache and PHP
sudo apt-get update && sudo apt-get install apache2 php7.0 -y

# Download and install the Google Cloud Ops Agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

# Stop execution if any command fails
set -e

# Backup the existing Ops Agent config file
sudo cp /etc/google-cloud-ops-agent/config.yaml /etc/google-cloud-ops-agent/config.yaml.bak

# Configure the Ops Agent to collect metrics and logs from Apache
sudo tee /etc/google-cloud-ops-agent/config.yaml > /dev/null << EOF
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
EOF

# Restart the Ops Agent to apply new configuration
sudo service google-cloud-ops-agent restart
sleep 60

EOF_END

# Copy the prepare_disk.sh script to the VM
gcloud compute scp prepare_disk.sh quickstart-vm:/tmp \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet

# SSH into the VM and run the prepare_disk.sh script
gcloud compute ssh quickstart-vm \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet \
  --command="bash /tmp/prepare_disk.sh"

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}               ✅ TASK 2 COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}               ✅ TASK 3 COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your Task 2 & 3 progress."
echo "${GREEN_TEXT}${BOLD_TEXT} Wait for 10-15 seconds for successfully completion of the Assessment."
sleep 20
echo ""

# 📡 Setup Notification Channel
echo "${CYAN_TEXT}${BOLD}Starting Task 5. Create an alerting policys...${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD}🔔 Setting up monitoring notification channel...${RESET_FORMAT}"
cat > email-channel.json <<EOF_END
{
  "type": "email",
  "displayName": "quickgcplab",
  "description": "Awesome",
  "labels": {
    "email_address": "$USER_EMAIL"
  }
}
EOF_END

# Create the notification channel in Cloud Monitoring
gcloud beta monitoring channels create --channel-content-from-file="email-channel.json"

# 🧾 Fetch Channel ID
echo "${GREEN_TEXT}${BOLD}🔍 Fetching notification channel ID...${RESET_FORMAT}"
email_channel_info=$(gcloud beta monitoring channels list)
email_channel_id=$(echo "$email_channel_info" | grep -oP 'name: \K[^ ]+' | head -n 1)

# 🛎️ Create Alert Policy
echo "${YELLOW_TEXT}${BOLD}📈 Creating alert policy for Apache traffic...${RESET_FORMAT}"
cat > vm-alert-policy.json <<EOF_END
{
  "displayName": "Apache traffic above threshold",
  "userLabels": {},
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
    "autoClose": "1800s",
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

gcloud alpha monitoring policies create --policy-from-file=vm-alert-policy.json

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}               ✅ TASK 5 COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your Task 5 progress."
echo "${GREEN_TEXT}${BOLD_TEXT} Wait for 10-15 seconds for successfully completion of the Assessment."
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
