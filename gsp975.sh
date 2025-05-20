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
echo "${CYAN_TEXT}${BOLD_TEXT}       Rate Limiting with Cloud Armor     ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-----------------------------------------------------------------------${RESET_FORMAT}"
echo ""

# 🌍 Fetching Region
# echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔄 Fetching Region...${RESET_FORMAT}"
# export REGION=$(gcloud compute project-info describe \
# --format="value(commonInstanceMetadata.items[google-compute-default-region])")
# echo ""

# # 🗺️ Fetching Zone
# echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔄 Fetching Zone...${RESET_FORMAT}"
# export ZONE=$(gcloud compute project-info describe \
# --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
# echo ""

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

read -p "${MAGENTA_TEXT}${BOLD_TEXT}Enter REGION 1: ${RESET_FORMAT}" REGION
read -p "${MAGENTA_TEXT}${BOLD_TEXT}Enter REGION 2: ${RESET_FORMAT}" REGION_3

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating firewall rule to allow HTTP traffic (tcp:80) from all sources...${RESET_FORMAT}"
gcloud compute firewall-rules create default-allow-http \
  --network=default \
  --direction=INGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=http-server

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating firewall rule to allow health check traffic from GCP IP ranges...${RESET_FORMAT}"
gcloud compute firewall-rules create default-allow-health-check \
  --network=default \
  --direction=INGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=tcp \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=http-server

# =============================
# Create Instance Template for REGION
# =============================
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating instance template for ${REGION}...${RESET_FORMAT}"
gcloud compute instance-templates create ${REGION}-template \
  --machine-type=e2-medium \
  --network=default \
  --subnet=default \
  --metadata=startup-script-url=gs://cloud-training/gcpnet/httplb/startup.sh \
  --tags=http-server \
  --no-address

# =============================
# Create Instance Template for REGION_3
# =============================
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating instance template for ${REGION_3}...${RESET_FORMAT}"
gcloud compute instance-templates create ${REGION_3}-template \
  --machine-type=e2-medium \
  --network=default \
  --subnet=default \
  --metadata=startup-script-url=gs://cloud-training/gcpnet/httplb/startup.sh \
  --tags=http-server \
  --no-address

# =============================
# Create Managed Instance Group in REGION
# =============================
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating managed instance group in ${REGION}...${RESET_FORMAT}"
gcloud compute instance-groups managed create ${REGION}-mig \
  --region=${REGION} \
  --template=${REGION}-template \
  --size=1 \
  --target-distribution-shape EVEN

echo "${BLUE_TEXT}${BOLD_TEXT}---> Configuring autoscaling for ${REGION}-mig...${RESET_FORMAT}"
gcloud compute instance-groups managed set-autoscaling ${REGION}-mig \
  --region=${REGION} \
  --cool-down-period=45 \
  --max-num-replicas=5 \
  --min-num-replicas=1 \
  --target-cpu-utilization=0.80

# =============================
# Create Managed Instance Group in REGION_3
# =============================
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating managed instance group in ${REGION_3}...${RESET_FORMAT}"
gcloud compute instance-groups managed create ${REGION_3}-mig \
  --region=${REGION_3} \
  --template=${REGION_3}-template \
  --size=1 \
  --target-distribution-shape EVEN

echo "${BLUE_TEXT}${BOLD_TEXT}---> Configuring autoscaling for ${REGION_3}-mig...${RESET_FORMAT}"
gcloud compute instance-groups managed set-autoscaling ${REGION_3}-mig \
  --region=${REGION_3} \
  --cool-down-period=45 \
  --max-num-replicas=5 \
  --min-num-replicas=1 \
  --target-cpu-utilization=0.80

# =============================
# Create Backend Service
# =============================
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating backend service http-backend...${RESET_FORMAT}"
gcloud compute backend-services create http-backend \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=http-health-check \
  --global \
  --enable-logging \
  --log-sample-rate=1

# =============================
# Add REGION MIG as Backend with RATE balancing mode
# =============================
echo "${BLUE_TEXT}${BOLD_TEXT}---> Adding ${REGION}-mig to backend service...${RESET_FORMAT}"
gcloud compute backend-services add-backend http-backend \
  --instance-group=${REGION}-mig \
  --instance-group-region=${REGION} \
  --balancing-mode=RATE \
  --max-rate-per-instance=50 \
  --capacity-scaler=1.0 \
  --global

# =============================
# Add REGION_3 MIG as Backend with UTILIZATION balancing mode
# =============================
echo "${BLUE_TEXT}${BOLD_TEXT}---> Adding ${REGION_3}-mig to backend service...${RESET_FORMAT}"
gcloud compute backend-services add-backend http-backend \
  --instance-group=${REGION_3}-mig \
  --instance-group-region=${REGION_3} \
  --balancing-mode=UTILIZATION \
  --max-utilization=0.8 \
  --capacity-scaler=1.0 \
  --global

# =============================
# Create Health Check
# =============================
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating health check http-health-check...${RESET_FORMAT}"
gcloud compute health-checks create tcp http-health-check \
  --port=80

# Variables
LB_NAME="http-lb"

# =============================
# Create HTTP Load Balancer Frontend for IPv4 (Ephemeral IP)
# =============================
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating frontend configuration with IPv4 ephemeral IP...${RESET_FORMAT}"
gcloud compute forwarding-rules create ${LB_NAME}-ipv4 \
  --load-balancing-scheme=EXTERNAL \
  --address= \
  --ports=80 \
  --target-http-proxy=${LB_NAME}-http-proxy \
  --global

# =============================
# Create HTTP Load Balancer Frontend for IPv6 (Auto-allocate IP)
# =============================
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating frontend configuration with IPv6 auto-allocated IP...${RESET_FORMAT}"
gcloud compute forwarding-rules create ${LB_NAME}-ipv6 \
  --load-balancing-scheme=EXTERNAL \
  --ip-version=IPV6 \
  --address= \
  --ports=80 \
  --target-http-proxy=${LB_NAME}-http-proxy \
  --global

# =============================
# NOTE:
# You need to create the target HTTP proxy and URL map before creating forwarding rules.
# The steps for that are usually:
# 1. Create a URL map pointing to your backend service.
# 2. Create a target HTTP proxy referencing that URL map.
# These are prerequisite steps.
# =============================
echo "${BLUE_TEXT}${BOLD_TEXT}---> ---> Ensure the target HTTP proxy and URL map are created before forwarding rules.${RESET_FORMAT}"

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
