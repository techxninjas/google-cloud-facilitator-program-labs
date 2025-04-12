#!/bin/bash

# Define color variables
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

# Spinner animation
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Clear the screen
clear

# Header Box
echo "${BLUE_TEXT}${BOLD_TEXT}=============================================="
echo "           INITIATING EXECUTION...           "
echo "==============================================${RESET_FORMAT}"
echo

# Task 1
echo "${MAGENTA_TEXT}${BOLD_TEXT}┌────────────────────────────────────────────┐"
echo "│ Step 1: Fetching Default Compute Zone      │"
echo "└────────────────────────────────────────────┘${RESET_FORMAT}"
sleep 0.5 &
spinner
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# Task 2
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}┌────────────────────────────────────────────┐"
echo "│ Step 2: Creating GKE Cluster (gmp-cluster) │"
echo "└────────────────────────────────────────────┘${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}This may take a few minutes (Based on your Network Speed)${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}So just wait...${RESET_FORMAT}"
gcloud container clusters create gmp-cluster --num-nodes=3 --zone=$ZONE

# Task 3
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}┌────────────────────────────────────────────┐"
echo "│ Step 3: Fetching Cluster Credentials       │"
echo "└────────────────────────────────────────────┘${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}Allowing kubectl to access your cluster...${RESET_FORMAT}"
gcloud container clusters get-credentials gmp-cluster --zone=$ZONE

echo
echo "${CYAN_TEXT}${BOLD_TEXT}✔ Please check your task 3 progress in the cluster dashboard.${RESET_FORMAT}"

# Task 4
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}┌────────────────────────────────────────────┐"
echo "│ Step 4: Setting up Prometheus + Metrics    │"
echo "└────────────────────────────────────────────┘${RESET_FORMAT}"
kubectl create ns gmp-test
kubectl -n gmp-test apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/v0.2.3/manifests/setup.yaml
kubectl -n gmp-test apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/v0.2.3/manifests/operator.yaml
kubectl -n gmp-test apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/v0.2.3/examples/example-app.yaml

cat > op-config.yaml <<'EOF_END'
apiVersion: monitoring.googleapis.com/v1alpha1
collection:
  filter:
    matchOneOf:
    - '{job="prom-example"}'
    - '{__name__=~"job:.+"}'
kind: OperatorConfig
metadata:
  annotations:
    components.gke.io/layer: addon
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"monitoring.googleapis.com/v1alpha1","kind":"OperatorConfig","metadata":{"annotations":{"components.gke.io/layer":"addon"},"labels":{"addonmanager.kubernetes.io/mode":"Reconcile"},"name":"config","namespace":"gmp-public"}}
  creationTimestamp: "2022-03-14T22:34:23Z"
  generation: 1
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
  name: config
  namespace: gmp-public
  resourceVersion: "2882"
  uid: 4ad23359-efeb-42bb-b689-045bd704f295
EOF_END

export PROJECT=$(gcloud config get-value project)
gsutil mb -p $PROJECT gs://$PROJECT
gsutil cp op-config.yaml gs://$PROJECT
gsutil -m acl set -R -a public-read gs://$PROJECT

echo
echo "${CYAN_TEXT}${BOLD_TEXT}✔ Please check your Task 4 progress — Filter Exported Metrics."
echo "✔ LAB COMPLETED SUCCESSFULLY!${RESET_FORMAT}"

# Final Banner
echo
echo "${GREEN_TEXT}${BOLD_TEXT}=============================================="
echo "               🎉 ALL DONE! 🎉                "
echo "     Prometheus setup completed on GKE.      "
echo "==============================================${RESET_FORMAT}"

# Subscription
echo
echo -e "${RED_TEXT}${BOLD_TEXT}Subscribe to our Channel (TechXNinjas):${RESET_FORMAT} ${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@TechXNinjas${RESET_FORMAT}"
echo -e "${RED_TEXT}${BOLD_TEXT}Join to our WhatsApp Group for all Doubts and Guidance:${RESET_FORMAT} ${BLUE_TEXT}${BOLD_TEXT}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo -e "${RED_TEXT}${BOLD_TEXT}Follow me on LinkedIn:${RESET_FORMAT} ${BLUE_TEXT}${BOLD_TEXT}https://www.linkedin.com/in/iaadillatif/${RESET_FORMAT}"
