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
echo "${CYAN_TEXT}${BOLD_TEXT}             Managing Deployments Using Kubernetes Engine           ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-----------------------------------------------------------------------${RESET_FORMAT}"
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

read -p "${MAGENTA_TEXT}${BOLD_TEXT}Enter the Zone of your Lab in Set the zone: ${RESET_FORMAT}" ZONE
gcloud config set compute/zone $ZONE

echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying required files from the GCS bucket...${RESET_FORMAT}"
gsutil -m cp -r gs://spls/gsp053/orchestrate-with-kubernetes .

cd orchestrate-with-kubernetes/kubernetes

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a Kubernetes cluster named 'bootcamp'...${RESET_FORMAT}"
gcloud container clusters create bootcamp \
        --machine-type e2-small \
        --num-nodes 3 \
        --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"

echo "${BLUE_TEXT}${BOLD_TEXT}---> Updating the image version in the auth deployment file...${RESET_FORMAT}"
sed -i 's/image: "kelseyhightower\/auth:2.0.0"/image: "kelseyhightower\/auth:1.0.0"/' deployments/auth.yaml

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the auth deployment...${RESET_FORMAT}"
kubectl create -f deployments/auth.yaml

echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching the list of deployments...${RESET_FORMAT}"
kubectl get deployments

echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching the list of pods...${RESET_FORMAT}"
kubectl get pods

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the auth service...${RESET_FORMAT}"
kubectl create -f services/auth.yaml

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the hello deployment and service...${RESET_FORMAT}"
kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a secret for TLS certificates...${RESET_FORMAT}"
kubectl create secret generic tls-certs --from-file tls/

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a ConfigMap for the Nginx frontend configuration...${RESET_FORMAT}"
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf

echo "${BLUE_TEXT}${BOLD_TEXT}---> Deploying the frontend application...${RESET_FORMAT}"
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml

echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching the frontend service details...${RESET_FORMAT}"
kubectl get services frontend

echo "${BLUE_TEXT}${BOLD_TEXT}---> Scaling the hello deployment to 5 replicas...${RESET_FORMAT}"
sleep 10
kubectl scale deployment hello --replicas=5

echo "${BLUE_TEXT}${BOLD_TEXT}---> Counting the hello pods...${RESET_FORMAT}"
kubectl get pods | grep hello- | wc -l

echo "${BLUE_TEXT}${BOLD_TEXT}---> Scaling the hello deployment back to 3 replicas...${RESET_FORMAT}"
kubectl scale deployment hello --replicas=3

echo "${BLUE_TEXT}${BOLD_TEXT}---> Counting the hello pods again...${RESET_FORMAT}"
kubectl get pods | grep hello- | wc -l

echo "${BLUE_TEXT}${BOLD_TEXT}---> Updating the image version in the hello deployment file...${RESET_FORMAT}"
sed -i 's/image: "kelseyhightower\/auth:1.0.0"/image: "kelseyhightower\/auth:2.0.0"/' deployments/hello.yaml

echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching the list of ReplicaSets...${RESET_FORMAT}"
kubectl get replicaset

echo "${BLUE_TEXT}${BOLD_TEXT}---> Checking the rollout history of the hello deployment...${RESET_FORMAT}"
kubectl rollout history deployment/hello

echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching pod names and their images...${RESET_FORMAT}"
kubectl get pods -o jsonpath --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

echo "${BLUE_TEXT}${BOLD_TEXT}---> Resuming the rollout of the hello deployment...${RESET_FORMAT}"
kubectl rollout resume deployment/hello

echo "${BLUE_TEXT}${BOLD_TEXT}---> Checking the rollout status of the hello deployment...${RESET_FORMAT}"
kubectl rollout status deployment/hello

echo "${BLUE_TEXT}${BOLD_TEXT}---> Undoing the last rollout of the hello deployment...${RESET_FORMAT}"
kubectl rollout undo deployment/hello

echo "${BLUE_TEXT}${BOLD_TEXT}---> Checking the rollout history again...${RESET_FORMAT}"
kubectl rollout history deployment/hello

echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching pod names and their images again...${RESET_FORMAT}"
kubectl get pods -o jsonpath --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the hello-canary deployment...${RESET_FORMAT}"
kubectl create -f deployments/hello-canary.yaml

echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching the list of deployments...${RESET_FORMAT}"
kubectl get deployments

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
