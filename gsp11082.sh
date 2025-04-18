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
echo "${CYAN_TEXT}${BOLD}     5th Lab: Monitor an Apache Web Server using Ops Agent     ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}        Level 2: Cloud Infrastructure & API Essentials           ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}===========================================================🚀${RESET_FORMAT}"
echo ""

# 🌍 Input Zone
# Get the default compute zone for the current project
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

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

  # ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}               ✅ TASK 1 COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your Task 1 progress."
echo ""

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

# Create a JSON file to define an email notification channel for alerts
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

# Get the ID of the newly created email notification channel
email_channel_info=$(gcloud beta monitoring channels list)
email_channel_id=$(echo "$email_channel_info" | grep -oP 'name: \K[^ ]+' | head -n 1)

# Create an alerting policy that monitors Apache traffic
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

# Create the alert policy using the defined JSON file
gcloud alpha monitoring policies create --policy-from-file=vm-alert-policy.json
