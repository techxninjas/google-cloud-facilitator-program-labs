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
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}                  Continuous Delivery with Google Cloud Deploy             ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------------------------------${RESET_FORMAT}"
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

echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Enabling required Google Cloud services for deployment...${RESET_FORMAT}"
gcloud services enable \
container.googleapis.com \
clouddeploy.googleapis.com \
artifactregistry.googleapis.com \
cloudbuild.googleapis.com \
clouddeploy.googleapis.com
echo ""

sleep 30

# Create GKE clusters
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Creating GKE clusters: test, staging, and prod (asynchronously)...${RESET_FORMAT}"
gcloud container clusters create test --node-locations=$ZONE --num-nodes=1 --async
gcloud container clusters create staging --node-locations=$ZONE --num-nodes=1 --async
gcloud container clusters create prod --node-locations=$ZONE --num-nodes=1 --async
echo ""

# List GKE clusters
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Listing GKE clusters with name and status...${RESET_FORMAT}"
gcloud container clusters list --format="csv(name,status)"
echo ""

# Create Artifact Registry
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Creating Docker Artifact Registry named 'web-app'...${RESET_FORMAT}"
gcloud artifacts repositories create web-app \
  --description="Image registry for tutorial web app" \
  --repository-format=docker \
  --location=$REGION
echo ""

# Clone the deployment tutorial repo
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Cloning the Cloud Deploy tutorial repository...${RESET_FORMAT}"
cd ~/
git clone https://github.com/GoogleCloudPlatform/cloud-deploy-tutorials.git
cd cloud-deploy-tutorials
git checkout c3cae80 --quiet
cd tutorials/base

# Generate skaffold.yaml from template
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Generating 'skaffold.yaml' from template using environment variables...${RESET_FORMAT}"
envsubst < clouddeploy-config/skaffold.yaml.template > web/skaffold.yaml
cat web/skaffold.yaml

# Build Docker image using Skaffold
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Building Docker image using Skaffold...${RESET_FORMAT}"
cd web
skaffold build --interactive=false \
  --default-repo $REGION-docker.pkg.dev/$PROJECT_ID/web-app \
  --file-output artifacts.json
cd ..
echo ""

# List built Docker images in Artifact Registry
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Listing Docker images in the Artifact Registry...${RESET_FORMAT}"
gcloud artifacts docker images list \
  $REGION-docker.pkg.dev/$PROJECT_ID/web-app \
  --include-tags \
  --format yaml
echo ""

# Create the Cloud Deploy delivery pipeline
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Creating the Cloud Deploy delivery pipeline configuration...${RESET_FORMAT}"
cp clouddeploy-config/delivery-pipeline.yaml.template clouddeploy-config/delivery-pipeline.yaml
gcloud beta deploy apply --file=clouddeploy-config/delivery-pipeline.yaml
echo ""

# Describe the delivery pipeline
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Describing the delivery pipeline 'web-app'...${RESET_FORMAT}"
gcloud beta deploy delivery-pipelines describe web-app
echo ""

# Wait until all GKE clusters are in RUNNING state
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Waiting for all GKE clusters to reach RUNNING state...${RESET_FORMAT}"
while true; do
  cluster_statuses=$(gcloud container clusters list --format="csv(name,status)" | tail -n +2)
  all_running=true
  while IFS=, read -r cluster_name cluster_status; do
    if [[ "$cluster_status" != "RUNNING" ]]; then
      all_running=false
      break
    fi
  done <<< "$cluster_statuses"
  if $all_running; then
    echo "All clusters are in RUNNING state."
    break
  fi
  sleep 10
done
echo ""

# Get credentials and rename kube contexts
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Fetching credentials and renaming kube-contexts for each environment...${RESET_FORMAT}"
CONTEXTS=("test" "staging" "prod")
for CONTEXT in ${CONTEXTS[@]}; do
    gcloud container clusters get-credentials ${CONTEXT} --region ${REGION}
    kubectl config rename-context gke_${PROJECT_ID}_${REGION}_${CONTEXT} ${CONTEXT}
done

# Apply Kubernetes namespace config
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Applying Kubernetes namespace configuration to each environment...${RESET_FORMAT}"
for CONTEXT in ${CONTEXTS[@]}; do
    kubectl --context ${CONTEXT} apply -f kubernetes-config/web-app-namespace.yaml
done

# Create deploy targets for each environment
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Creating deploy targets using templates for test, staging, and prod...${RESET_FORMAT}"
for CONTEXT in ${CONTEXTS[@]}; do
    envsubst < clouddeploy-config/target-$CONTEXT.yaml.template > clouddeploy-config/target-$CONTEXT.yaml
    gcloud beta deploy apply --file clouddeploy-config/target-$CONTEXT.yaml
done
echo ""

# List all deploy targets
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Listing all created deploy targets...${RESET_FORMAT}"
gcloud beta deploy targets list
echo ""

# Create a release
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Creating a release 'web-app-001'...${RESET_FORMAT}"
gcloud beta deploy releases create web-app-001 \
--delivery-pipeline web-app \
--build-artifacts web/artifacts.json \
--source web/
echo ""

# List rollouts
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Listing rollouts for release 'web-app-001'...${RESET_FORMAT}"
gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001
echo ""

# Wait for rollout to complete
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Waiting for rollout to complete...${RESET_FORMAT}"
while true; do
  status=$(gcloud beta deploy rollouts list --delivery-pipeline web-app --release web-app-001 --format="value(state)" | head -n 1)
  if [ "$status" == "SUCCEEDED" ]; then
    break
  fi
  echo "it's creating now please wait sometimes..."
  sleep 10
done
echo ""

# Verify deployment in test
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Verifying deployment in 'test' environment...${RESET_FORMAT}"
kubectx test
kubectl get all -n web-app
echo ""

# Promote release
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Promoting release 'web-app-001' to next target...${RESET_FORMAT}"
gcloud beta deploy releases promote \
--delivery-pipeline web-app \
--release web-app-001 \
--quiet
echo ""

# Wait for rollout after promotion
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Waiting for rollout to complete after promotion...${RESET_FORMAT}"
while true; do
  status=$(gcloud beta deploy rollouts list --delivery-pipeline web-app --release web-app-001 --format="value(state)" | head -n 1)
  if [ "$status" == "SUCCEEDED" ]; then
    break
  fi
  echo "it's creating now please wait sometimes..."
  sleep 10
done
echo ""

# Promote again
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Promoting release 'web-app-001' again...${RESET_FORMAT}"
gcloud beta deploy releases promote \
--delivery-pipeline web-app \
--release web-app-001 \
--quiet
echo ""

# Wait until rollout reaches approval stage
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Waiting for rollout to reach 'PENDING_APPROVAL' state...${RESET_FORMAT}"
while true; do
  status=$(gcloud beta deploy rollouts list --delivery-pipeline web-app --release web-app-001 --format="value(state)" | head -n 1)
  if [ "$status" == "PENDING_APPROVAL" ]; then
    break
  fi
  echo "it's creating now please wait sometimes..."
  sleep 10
done
echo ""

# Approve the final rollout to prod
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Approving final rollout to 'prod'...${RESET_FORMAT}"
gcloud beta deploy rollouts approve web-app-001-to-prod-0001 \
--delivery-pipeline web-app \
--release web-app-001 \
--quiet
echo ""

# Wait for the final rollout to finish
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Waiting for the final rollout to finish...${RESET_FORMAT}"
while true; do
  status=$(gcloud beta deploy rollouts list --delivery-pipeline web-app --release web-app-001 --format="value(state)" | head -n 1)
  if [ "$status" == "SUCCEEDED" ]; then
    break
  fi
  echo "it's creating now please wait sometimes..."
  sleep 10
done
echo ""

# Verify deployment in prod
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> Verifying deployment in 'prod' environment...${RESET_FORMAT}"
kubectx prod
kubectl get all -n web-app

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
