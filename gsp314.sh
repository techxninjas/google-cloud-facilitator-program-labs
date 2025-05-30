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
echo "${CYAN_TEXT}${BOLD_TEXT}             Set Up a Google Cloud Network: Challenge Lab           ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-----------------------------------------------------------------------${RESET_FORMAT}"
echo ""

# Author: Aadil Latif
# Script: TechX Ninjas Lab Setup
# Version: 1.0

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

# Taking user input
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter VPC Network Name (Check Task 1: Step 1): ${RESET_FORMAT}" NETWORK_NAME
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter 1st Subnet Name (Check Task 1: Step 2 that consists subnet-a): ${RESET_FORMAT}" SUBNET_A_NAME
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter 2nd Subnet Name (Check Task 1: Step 3 that consists subnet-b): ${RESET_FORMAT}" SUBNET_B_NAME
echo

# Taking Firewall Rule Names and Zones
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter Firewall Rule 1 Name (Check Task 2: Step 1): ${RESET_FORMAT}" FIREWALL_RULE1
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter Firewall Rule 2 Name (Check Task 2: Step 2): ${RESET_FORMAT}" FIREWALL_RULE2
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter Firewall Rule 3 Name (Check Task 2: Step 3): ${RESET_FORMAT}" FIREWALL_RULE3
echo

# Taking Zones Input
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter the 1st Zone for the instance us-test-01 in ${SUBNET_A_NAME} (Check Task 3: Step 1): ${RESET_FORMAT}" ZONE1
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter the 2nd Zone for the instance us-test-02 in ${SUBNET_B_NAME} (Check Task 3: Step 2): ${RESET_FORMAT}" ZONE2
echo

# Extracting 1st Region from 1st Zone
if [[ -z "$ZONE1" ]]; then
    echo "${RED_TEXT}${BOLD_TEXT}Error: Zone1 cannot be empty. Please provide a valid zone.${RESET_FORMAT}"
    exit 1
fi
REGION1=$(gcloud compute zones describe $ZONE1 --format='value(region)')
# If not fetched, then give an error message and take an input for Region1
if [ -z "$REGION1" ]; then
    echo "${RED_TEXT}${BOLD_TEXT}Error: Unable to fetch region for $ZONE1.${RESET_FORMAT}"
    read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Please enter the Region for $ZONE1: ${RESET_FORMAT}" REGION1
    echo
fi

# Extracting 2nd Region from 2nd Zone
if [[ -z "$ZONE2" ]]; then
    echo "${RED_TEXT}${BOLD_TEXT}Error: Zone2 cannot be empty. Please provide a valid zone.${RESET_FORMAT}"
    exit 1
fi
REGION2=$(gcloud compute zones describe $ZONE2 --format='value(region)')
# If not fetched, then give an error message and take an input for Region2
if [ -z "$REGION2" ]; then
    echo "${RED_TEXT}${BOLD_TEXT}Error: Unable to fetch region for $ZONE2.${RESET_FORMAT}"
    read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Please enter the Region for $ZONE2: ${RESET_FORMAT}" REGION2
    echo
fi

# Variables
INSTANCE1="us-test-01"
INSTANCE2="us-test-02"

# Function to check for errors
check_error() {
    if [ $? -ne 0 ]; then
        echo "${RED_TEXT}${BOLD_TEXT}Error: Something went wrong! Exiting.${RESET_FORMAT}"
        exit 1
    fi
}

# Step 1: Create VPC Network and Subnets
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating VPC Network and Subnets...${RESET_FORMAT}"
gcloud compute networks create $NETWORK_NAME \
    --subnet-mode=custom --bgp-routing-mode=regional
check_error
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Subnet A named ${SUBNET_A_NAME}...${RESET_FORMAT}"
gcloud compute networks subnets create $SUBNET_A_NAME \
    --network=$NETWORK_NAME --region=$REGION1 \
    --range=10.10.10.0/24 --stack-type=IPV4_ONLY
check_error
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Subnet B named ${SUBNET_B_NAME}...${RESET_FORMAT}"
gcloud compute networks subnets create $SUBNET_B_NAME \
    --network=$NETWORK_NAME --region=$REGION2 \
    --range=10.10.20.0/24 --stack-type=IPV4_ONLY
check_error
echo

# ✅ Completion Message
echo "${GREEN_TEXT}${BOLD_TEXT}---> VPC Network and Subnets created successfully!${RESET_FORMAT}"
echo
# Wait for a few seconds before proceeding
sleep 5

# Step 2: Create Firewall Rules
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Firewall Rule 1 named ${FIREWALL_RULE1}...${RESET_FORMAT}"
gcloud compute firewall-rules create $FIREWALL_RULE1 \
    --network=$NETWORK_NAME --priority=1000 --direction=INGRESS \
    --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0
check_error
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Firewall Rule 2 named ${FIREWALL_RULE2}...${RESET_FORMAT}"
gcloud compute firewall-rules create $FIREWALL_RULE2 \
    --network=$NETWORK_NAME --priority=65535 --direction=INGRESS \
    --action=ALLOW --rules=tcp:3389 --source-ranges=0.0.0.0/24
check_error
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Firewall Rule 3 named ${FIREWALL_RULE3}...${RESET_FORMAT}"
gcloud compute firewall-rules create $FIREWALL_RULE3 \
    --network=$NETWORK_NAME --priority=1000 --direction=INGRESS \
    --action=ALLOW --rules=icmp --source-ranges=10.10.10.0/24,10.10.20.0/24
check_error
echo

# ✅ Completion Message
echo "${GREEN_TEXT}${BOLD_TEXT}---> Firewall rules created successfully!${RESET_FORMAT}"
echo
# Wait for a few seconds before proceeding 
sleep 5

# Step 3: Create VM Instances
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Virtual Machine 1 named ${INSTANCE1}...${RESET_FORMAT}"
gcloud compute instances create $INSTANCE1 \
    --zone=$ZONE1 --machine-type=e2-micro --subnet=$SUBNET_A_NAME \
    --tags=allow-ssh,allow-icmp
check_error
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Virtual Machine 2 named ${INSTANCE2}...${RESET_FORMAT}"
gcloud compute instances create $INSTANCE2 \
    --zone=$ZONE2 --machine-type=e2-micro --subnet=$SUBNET_B_NAME \
    --tags=allow-ssh,allow-icmp
check_error
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Waiting for VM instances to be ready...${RESET_FORMAT}"
for i in {1..20}; do
    echo -ne "${CYAN_TEXT}⏳ Waiting for VM instances to be ready... ${i}/20 seconds\r${RESET_FORMAT}"
    sleep 1
done

# ✅ VM Instances Created Successfully
echo "${GREEN_TEXT}${BOLD_TEXT}VM instances created successfully!${RESET_FORMAT}"
echo

# Step 4: Verify Connection
echo "${GREEN_TEXT}${BOLD_TEXT}---> Verifying Connection Between Instances...${RESET_FORMAT}"
INSTANCE2_IP=$(gcloud compute instances describe $INSTANCE2 --zone=$ZONE2 --format='get(networkInterfaces[0].networkIP)')
check_error
echo

gcloud compute ssh $INSTANCE1 --zone=$ZONE1 --command="ping -c 3 $INSTANCE2_IP"
check_error
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
