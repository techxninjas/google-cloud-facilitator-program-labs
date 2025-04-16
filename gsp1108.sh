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
BRIGHT_PURPLE='\033[1;35m'
BRIGHT_CYAN='\033[1;36m'

# 💡 Start-Up Banner 
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}       4th Game: Level 1: Deploy & Configure VMs       ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

# 💡 Lab Info
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}            5th Lab: Monitor an Apache Web Server using Ops Agent                  ${RESET}" 
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------------------------------------${RESET}"
echo ""

# 🚀 Task Execution Init
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}         🚀 INITIATING THE TASK EXECUTION...           ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

#----------------------------------------------------start--------------------------------------------------#

# ✅ Task 1: Create a Compute Engine VM instance
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

gcloud compute instances create quickstart-vm \
--zone=$ZONE \
--machine-type=e2-small \
--tags=http-server,https-server \
--create-disk=auto-delete=yes,boot=yes,device-name=quickstart-vm,image=projects/debian-cloud/global/images/debian-11-bullseye-v20241009,mode=rw,size=10,type=pd-balanced

# ✅ Checkpoint: Task 1 Complete!

# ✅ Task 2: Install an Apache Web Server
gcloud compute firewall-rules create allow-http-from-internet \
--target-tags=http-server \
--allow tcp:80 \
--source-ranges 0.0.0.0/0 \
--description="Allow HTTP from the internet"

gcloud compute firewall-rules create allow-https-from-internet \
--target-tags=https-server \
--allow tcp:443 \
--source-ranges 0.0.0.0/0 \
--description="Allow HTTPS from the internet"

# ✅ Checkpoint: Task 2 Complete!

# ✅ Task 3: Install and configure the Ops Agent
cat > prepare_disk.sh <<'EOF_END'
sudo apt-get update && sudo apt-get install apache2 php7.0 -y

curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

set -e
sudo cp /etc/google-cloud-ops-agent/config.yaml /etc/google-cloud-ops-agent/config.yaml.bak

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

sudo service google-cloud-ops-agent restart
sleep 60
EOF_END

gcloud compute scp prepare_disk.sh quickstart-vm:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet
gcloud compute ssh quickstart-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/prepare_disk.sh"

# ✅ Checkpoint: Task 3 Complete!

# ⚡ Task 4: Generate traffic and view metrics
# This task has no checkpoint

# ✅ Task 5: Create an alerting policy
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

gcloud beta monitoring channels create --channel-content-from-file="email-channel.json"

email_channel_info=$(gcloud beta monitoring channels list)
email_channel_id=$(echo "$email_channel_info" | grep -oP 'name: \K[^ ]+' | head -n 1)

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

# ✅ Checkpoint: Task 5 Complete!

# ⚡ Task 6: Test the alerting policy
# This task has no checkpoint

# 🎉 Completion Message
echo ""
echo "${BRIGHT_GREEN}${BOLD}🎉===========================================================${RESET}"
echo "${BRIGHT_GREEN}${BOLD}            ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!         ${RESET}"
echo "${BRIGHT_GREEN}${BOLD}🎉===========================================================${RESET}"
echo ""

# 📢 CTA
echo -e "${BRIGHT_YELLOW}${BOLD}🔔 Follow for more labs & tutorials:${RESET}"
echo -e "${BRIGHT_RED}${BOLD}YouTube Channel:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}Follow me on LinkedIn:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.linkedin.com/in/iaadillatif${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}LinkedIn Page:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.linkedin.com/company/techxninjas${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}Join WhatsApp Group:${RESET} ${BRIGHT_GREEN}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET}"
echo ""
