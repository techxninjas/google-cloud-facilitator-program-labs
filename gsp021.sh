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
echo "${CYAN_TEXT}${BOLD_TEXT}             Orchestrating the Cloud with Kubernetes            ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}----------------------------------------------------------------${RESET_FORMAT}"
echo ""

# 🌍 Fetching Region
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔄 Fetching Region...${RESET_FORMAT}"
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")
echo ""

# 🗺️ Fetching Zone
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔄 Fetching Zone...${RESET_FORMAT}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")
gcloud config set compute/zone $ZONE
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
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a GKE cluster named 'io'...${RESET_FORMAT}"
gcloud container clusters create io --zone=$ZONE
gcloud container clusters get-credentials io --zone=$ZONE

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying files from Google Cloud Storage...${RESET_FORMAT}"
gsutil cp -r gs://spls/gsp021/* .

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Changing directory to 'orchestrate-with-kubernetes/kubernetes'...${RESET_FORMAT}"
cd orchestrate-with-kubernetes/kubernetes

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating an NGINX deployment...${RESET_FORMAT}"
kubectl create deployment nginx --image=nginx:1.10.0

echo
for i in {1..20}; do
    echo -ne "${YELLOW_TEXT}⏳ Waiting for ${i}/20 seconds\r${RESET_FORMAT}"
    sleep 1
done

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Exposing the NGINX deployment on port 80...${RESET_FORMAT}"
kubectl expose deployment nginx --port 80 --type LoadBalancer

echo
for i in {1..90}; do
    echo -ne "${YELLOW_TEXT}⏳ Waiting for ${i}/90 seconds\r${RESET_FORMAT}"
    sleep 1
done

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching service details...${RESET_FORMAT}"
kubectl get services

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Changing back to 'orchestrate-with-kubernetes/kubernetes' directory...${RESET_FORMAT}"
cd ~/orchestrate-with-kubernetes/kubernetes

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a monolith pod...${RESET_FORMAT}"
kubectl create -f pods/monolith.yaml

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating TLS secrets and NGINX proxy configuration...${RESET_FORMAT}"
kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-proxy-conf --from-file nginx/proxy.conf

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a secure monolith pod...${RESET_FORMAT}"
kubectl create -f pods/secure-monolith.yaml

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a monolith service...${RESET_FORMAT}"
kubectl create -f services/monolith.yaml

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a firewall rule to allow traffic on port 31000...${RESET_FORMAT}"
gcloud compute firewall-rules create allow-monolith-nodeport \
  --allow=tcp:31000

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Labeling the secure-monolith pod...${RESET_FORMAT}"
kubectl get pods -l "app=monolith"
kubectl get pods -l "app=monolith,secure=enabled"
kubectl label pods secure-monolith 'secure=enabled'
kubectl get pods secure-monolith --show-labels
kubectl describe services monolith | grep Endpoints

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the auth deployment and service...${RESET_FORMAT}"
kubectl create -f deployments/auth.yaml
kubectl create -f services/auth.yaml

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the hello deployment and service...${RESET_FORMAT}"
kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the frontend configuration and deployment...${RESET_FORMAT}"
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml

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
echo

remove_temp_files() {
    echo "${YELLOW_TEXT}${BOLD_TEXT}Cleaning up temporary files...${RESET}"
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
