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
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}           Test Network Latency Between VMs       ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
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

read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter the 1st Zone (Check Task 1: Step 1): ${RESET_FORMAT}" ZONE_1
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter the 2nd Zone (Check Task 1: Step 2: 1st BOX): ${RESET_FORMAT}" ZONE_2
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter the 3rd Zone (Check Task 1: Step 2: 2nd BOX): ${RESET_FORMAT}" ZONE_3
echo

export REGION_1="${ZONE_1%-*}"
export REGION_2="${ZONE_2%-*}"
export REGION_3="${ZONE_3%-*}"

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Creating instances...${RESET_FORMAT}"
echo
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Creating instances in ${REGION_1}...${RESET_FORMAT}"
gcloud compute instances create us-test-01 \
--subnet subnet-$REGION_1 \
--zone $ZONE_1 \
--machine-type e2-standard-2 \
--tags ssh,http,rules
echo

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Creating instances in ${REGION_2}...${RESET_FORMAT}"
gcloud compute instances create us-test-02 \
--subnet subnet-$REGION_2 \
--zone $ZONE_2 \
--machine-type e2-standard-2 \
--tags ssh,http,rules
echo

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Creating instances in ${REGION_3}...${RESET_FORMAT}"
gcloud compute instances create us-test-03 \
--subnet subnet-$REGION_3 \
--zone $ZONE_3 \
--machine-type e2-standard-2 \
--tags ssh,http,rules
echo

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Creating instances in ${REGION_1} for Task 3...${RESET_FORMAT}"
gcloud compute instances create us-test-04 \
--subnet subnet-$REGION_1 \
--zone $ZONE_1 \
--tags ssh,http
echo

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Preparing instances with necessary tools...${RESET_FORMAT}"
echo

cat > prepare_disk1.sh <<'EOF_END'
sudo apt-get update
sudo apt-get -y install traceroute mtr tcpdump iperf whois host dnsutils siege
traceroute www.icann.org

EOF_END
echo

# Copying the script to the first instance and executing it
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Preparing disk on us-test-01...${RESET_FORMAT}"
gcloud compute scp prepare_disk1.sh us-test-01:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE_1 --quiet
echo

# Executing the script on the first instance
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Executing prepare_disk1.sh on us-test-01...${RESET_FORMAT}"
gcloud compute ssh us-test-01 --project=$DEVSHELL_PROJECT_ID --zone=$ZONE_1 --quiet --command="bash /tmp/prepare_disk1.sh"
echo

# Copying the script to the second instance and executing it
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Preparing disk on us-test-02...${RESET_FORMAT}"
cat > prepare_disk2.sh <<'EOF_END'
sudo apt-get update

sudo apt-get -y install traceroute mtr tcpdump iperf whois host dnsutils siege
EOF_END

echo

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Copying prepare_disk2.sh to us-test-02...${RESET_FORMAT}"
gcloud compute scp prepare_disk2.sh us-test-02:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE_2 --quiet
echo

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Executing prepare_disk2.sh on us-test-02...${RESET_FORMAT}"
gcloud compute ssh us-test-02 --project=$DEVSHELL_PROJECT_ID --zone=$ZONE_2 --quiet --command="bash /tmp/prepare_disk2.sh"
echo

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Preparing disk on us-test-03...${RESET_FORMAT}"
cat > prepare_disk.sh3 <<'EOF_END'
sudo apt-get update

sudo apt-get -y install traceroute mtr tcpdump iperf whois host dnsutils siege

EOF_END

echo

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Copying prepare_disk.sh3 to us-test-03...${RESET_FORMAT}"
gcloud compute scp prepare_disk.sh3 us-test-04:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE_1 --quiet
echo

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Executing prepare_disk.sh3 on us-test-04...${RESET_FORMAT}"
gcloud compute ssh us-test-04 --project=$DEVSHELL_PROJECT_ID --zone=$ZONE_1 --quiet --command="bash /tmp/prepare_disk.sh3"
echo

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Preparing disk on mc-server...${RESET_FORMAT}"
cat > prepare_disk.sh4 <<'EOF_END'

EOF_END

echo

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Checking available zones in $REGION...${RESET_FORMAT}"
AVAILABLE_ZONES=$(gcloud compute zones list --filter="region:($REGION)" --format="value(name)" | grep -v "$ZONE_1" | head -n 1)

if [ -z "$AVAILABLE_ZONES" ]; then
    echo "No alternative zones found in $REGION"
    exit 1
fi

ZONE=$AVAILABLE_ZONES

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Using alternative zone: $ZONE${RESET_FORMAT}"
gcloud compute scp prepare_disk.sh4 mc-server:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet
echo

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Executing prepare_disk.sh4 on mc-server...${RESET_FORMAT}"
gcloud compute ssh mc-server --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/prepare_disk.sh4"
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
