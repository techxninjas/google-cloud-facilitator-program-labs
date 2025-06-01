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
echo "${CYAN_TEXT}${BOLD_TEXT}         Implement Load Balancing on Compute Engine: Challenge Lab       ${RESET_FORMAT}"
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

# Collect user inputs
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter Instance Name: ${RESET_FORMAT}" INSTANCE_NAME
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter Firewall rule: ${RESET_FORMAT}" FIREWALL_RULE

# Export variables after collecting input
export INSTANCE_NAME FIREWALL_RULE
echo

export PORT=8082

# Create VPC network
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating VPC network...${RESET_FORMAT}"
gcloud compute networks create nucleus-vpc --subnet-mode=auto

# Create a compute instance
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a compute instance...${RESET_FORMAT}"
gcloud compute instances create $INSTANCE_NAME \
    --network nucleus-vpc \
    --zone $ZONE  \
    --machine-type e2-micro  \
    --image-family debian-12  \
    --image-project debian-cloud 

# Create a startup script for the instance
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a startup script for the instance...${RESET_FORMAT}"
cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF

# Create an instance template
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating an instance template...${RESET_FORMAT}"
gcloud compute instance-templates create web-server-template --region=$ZONE --machine-type e2-medium --metadata-from-file startup-script=startup.sh --network nucleus-vpc

# Create a target pool
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a target pool...${RESET_FORMAT}"
gcloud compute target-pools create nginx-pool --region=$REGION

# Create a managed instance group
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a managed instance group...${RESET_FORMAT}"
gcloud compute instance-groups managed create web-server-group --region=$REGION --base-instance-name web-server --size 2 --template web-server-template

# Create a firewall rule
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a firewall rule...${RESET_FORMAT}"
gcloud compute firewall-rules create $FIREWALL_RULE --network nucleus-vpc --allow tcp:80

# Create an HTTP health check
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating an HTTP health check...${RESET_FORMAT}"
gcloud compute http-health-checks create http-basic-check

# Set named ports for the instance group
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting named ports for the instance group...${RESET_FORMAT}"
gcloud compute instance-groups managed \
set-named-ports web-server-group --region=$REGION \
--named-ports http:80

# Create a backend service
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a backend service...${RESET_FORMAT}"
gcloud compute backend-services create web-server-backend --protocol HTTP --http-health-checks http-basic-check --global

# Add backend to the backend service
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Adding backend to the backend service...${RESET_FORMAT}"
gcloud compute backend-services add-backend web-server-backend --instance-group web-server-group --instance-group-region $REGION --global

# Create a URL map
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a URL map...${RESET_FORMAT}"
gcloud compute url-maps create web-server-map --default-service web-server-backend

# Create a target HTTP proxy
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a target HTTP proxy...${RESET_FORMAT}"
gcloud compute target-http-proxies create http-lb-proxy --url-map web-server-map

# Create a forwarding rule
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a forwarding rule...${RESET_FORMAT}"
gcloud compute forwarding-rules create http-content-rule --global --target-http-proxy http-lb-proxy --ports 80

# Create another forwarding rule for the firewall rule
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating another forwarding rule for the firewall rule...${RESET_FORMAT}"
gcloud compute forwarding-rules create $FIREWALL_RULE --global --target-http-proxy http-lb-proxy --ports 80

# List forwarding rules
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Listing all forwarding rules...${RESET_FORMAT}"
gcloud compute forwarding-rules list
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
