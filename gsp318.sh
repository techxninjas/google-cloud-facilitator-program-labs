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
echo "${CYAN_TEXT}${BOLD_TEXT}     Deploy Kubernetes Applications on Google Cloud: Challenge Lab     ${RESET_FORMAT}"
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

echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter the Repository Name (Check in the Left Panel of Lab): ${RESET_FORMAT}" REPO
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter the Docker Image (Check in the Left Panel of Lab): ${RESET_FORMAT}" DOCKER
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}===> Enter the Tag Name (Check in the Left Panel of Lab): ${RESET_FORMAT}" TAG
echo

export REPO="$REPO"
export DOCKER="$DOCKER"
export TAG="$TAG"

echo "${BLUE_TEXT}${BOLD_TEXT}---> Loading setup script...${RESET_FORMAT}"
source <(gsutil cat gs://cloud-training/gsp318/marking/setup_marking_v2.sh)

echo "${BLUE_TEXT}${BOLD_TEXT}---> Downloading and unpacking application...${RESET_FORMAT}"
gsutil cp gs://spls/gsp318/valkyrie-app.tgz .
tar -xzf valkyrie-app.tgz
cd valkyrie-app

echo "${YELLOW_TEXT}${BOLD_TEXT}Generating Dockerfile...${RESET_FORMAT}"
cat > Dockerfile <<EOF
FROM golang:1.10
WORKDIR /go/src/app
COPY source .
RUN go install -v
ENTRYPOINT ["app","-single=true","-port=8080"]
EOF

echo "${BLUE_TEXT}${BOLD_TEXT}Building Docker image...${RESET_FORMAT}"
docker build -t $DOCKER:$TAG .

echo "${BLUE_TEXT}${BOLD_TEXT}---> Running Step 1 script...${RESET_FORMAT}"
cd ..
./step1_v2.sh

echo "${BLUE_TEXT}${BOLD_TEXT}---> Starting Docker container...${RESET_FORMAT}"
cd valkyrie-app
docker run -d -p 8080:8080 $DOCKER:$TAG

echo "${BLUE_TEXT}${BOLD_TEXT}---> Running Step 2 script...${RESET_FORMAT}"
cd ..
./step2_v2.sh

cd valkyrie-app

echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting up Artifact Repository...${RESET_FORMAT}"
gcloud artifacts repositories create $REPO \
    --repository-format=docker \
    --location=$REGION \
    --description="awesome lab" \
    --async

echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting up Docker authentication...${RESET_FORMAT}"
gcloud auth configure-docker $REGION-docker.pkg.dev --quiet

sleep 30

echo "${BLUE_TEXT}${BOLD_TEXT}---> Tagging and uploading Docker image...${RESET_FORMAT}"

Image_ID=$(docker images --format='{{.ID}}')

docker tag $Image_ID $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/$REPO/$DOCKER:$TAG

docker push $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/$REPO/$DOCKER:$TAG

echo "${BLUE_TEXT}${BOLD_TEXT}---> Modifying Kubernetes deployment...${RESET_FORMAT}"
sed -i s#IMAGE_HERE#$REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/$REPO/$DOCKER:$TAG#g k8s/deployment.yaml

echo "${YELLOW_TEXT}${BOLD_TEXT}Setting up Kubernetes cluster...${RESET_FORMAT}"
gcloud container clusters get-credentials valkyrie-dev --zone $ZONE

echo "${BLUE_TEXT}${BOLD_TEXT}---> Deploying application to Kubernetes...${RESET_FORMAT}"
kubectl create -f k8s/deployment.yaml
kubectl create -f k8s/service.yaml

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
