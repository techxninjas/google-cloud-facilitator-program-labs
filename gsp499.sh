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
echo "${CYAN_TEXT}${BOLD_TEXT}            User Authentication: Identity-Aware Proxy                ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-----------------------------------------------------------------------${RESET_FORMAT}"
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

echo "${BLUE_TEXT}${BOLD_TEXT}Enabling the Identity-Aware Proxy (IAP) API...${RESET_FORMAT}"
gcloud services enable iap.googleapis.com
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Listing authenticated GCP accounts...${RESET_FORMAT}"
gcloud auth list
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Displaying current GCP project configuration...${RESET_FORMAT}"
gcloud config list project
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Downloading project files from Cloud Storage...${RESET_FORMAT}"
gsutil cp gs://spls/gsp499/user-authentication-with-iap.zip .
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Unzipping the downloaded project files...${RESET_FORMAT}"
unzip user-authentication-with-iap.zip
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Changing directory to 'user-authentication-with-iap'...${RESET_FORMAT}"
cd user-authentication-with-iap
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Enabling the App Engine Flexible Environment API...${RESET_FORMAT}"
gcloud services enable appengineflex.googleapis.com
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Changing directory to '1-HelloWorld'...${RESET_FORMAT}"
cd 1-HelloWorld
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Updating Python runtime in app.yaml to python39 for '1-HelloWorld'...${RESET_FORMAT}"
sed -i 's/python37/python39/g' app.yaml
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Creating a new App Engine application in region ${REGION}...${RESET_FORMAT}"
gcloud app create --region=$REGION
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Preparing to deploy the '1-HelloWorld' application. This may take a few minutes...${RESET_FORMAT}"
deploy_function() {
  yes | gcloud app deploy
}

deploy_success=false
while [ "$deploy_success" = false ]; do
  echo "${YELLOW_TEXT}${BOLD_TEXT}⏳  Attempting to deploy '1-HelloWorld'...${RESET_FORMAT}"
  if deploy_function; then
    echo "${GREEN_TEXT}${BOLD_TEXT}✅ '1-HelloWorld' deployed successfully!${RESET_FORMAT}"
    deploy_success=true
  else
    echo "${RED_TEXT}${BOLD_TEXT}❌ Deployment failed for '1-HelloWorld'. Retrying...${RESET_FORMAT}"
    for i in $(seq 10 -1 1); do
      echo -ne "${BLUE_TEXT}${BOLD_TEXT}\rRetrying in $i seconds... ${RESET_FORMAT}"
      sleep 1
    done
    echo -e "\r${RED_TEXT}${BOLD_TEXT}Retrying now!${RESET_FORMAT}"
  fi
done
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Changing directory to '~/user-authentication-with-iap/2-HelloUser'...${RESET_FORMAT}"
cd ~/user-authentication-with-iap/2-HelloUser
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Updating Python runtime in app.yaml for '2-HelloUser' to python39...${RESET_FORMAT}"
sed -i 's/python37/python39/g' app.yaml
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Preparing to deploy the '2-HelloUser' application. This may take a few minutes...${RESET_FORMAT}"
deploy_function() {
  yes | gcloud app deploy
}

deploy_success=false
while [ "$deploy_success" = false ]; do
  echo "${YELLOW_TEXT}${BOLD_TEXT}⏳  Attempting to deploy '2-HelloUser'...${RESET_FORMAT}"
  if deploy_function; then
    echo "${GREEN_TEXT}${BOLD_TEXT}✅ '2-HelloUser' deployed successfully!${RESET_FORMAT}"
    deploy_success=true
  else
    echo "${RED_TEXT}${BOLD_TEXT}❌ Deployment failed for '2-HelloUser'. Retrying...${RESET_FORMAT}"
    for i in $(seq 10 -1 1); do
      echo -ne "${BLUE_TEXT}${BOLD_TEXT}\rRetrying in $i seconds... ${RESET_FORMAT}"
      sleep 1
    done
    echo -e "\r${RED_TEXT}${BOLD_TEXT}Retrying now!${RESET_FORMAT}"
  fi
done
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Changing directory to '~/user-authentication-with-iap/3-HelloVerifiedUser'...${RESET_FORMAT}"
cd ~/user-authentication-with-iap/3-HelloVerifiedUser
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Updating Python runtime in app.yaml for '3-HelloVerifiedUser' to python39...${RESET_FORMAT}"
sed -i 's/python37/python39/g' app.yaml
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Preparing to deploy the '3-HelloVerifiedUser' application. This may take a few minutes...${RESET_FORMAT}"
deploy_function() {
  yes | gcloud app deploy
}

deploy_success=false
while [ "$deploy_success" = false ]; do
  echo "${YELLOW_TEXT}${BOLD_TEXT}⏳  Attempting to deploy '3-HelloVerifiedUser'...${RESET_FORMAT}"
  if deploy_function; then
    echo "${GREEN_TEXT}${BOLD_TEXT}✅ '3-HelloVerifiedUser' deployed successfully!${RESET_FORMAT}"
    deploy_success=true
  else
    echo "${RED_TEXT}${BOLD_TEXT}❌ Deployment failed for '3-HelloVerifiedUser'. Retrying...${RESET_FORMAT}"
    for i in $(seq 10 -1 1); do
      echo -ne "${BLUE_TEXT}${BOLD_TEXT}\rRetrying in $i seconds... ${RESET_FORMAT}"
      sleep 1
    done
    echo -e "\r${RED_TEXT}${BOLD_TEXT}Retrying now!${RESET_FORMAT}"
  fi
done
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Fetching your GCP account email...${RESET_FORMAT}"
EMAIL="$(gcloud config get-value core/account)"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Retrieving the application browsing link...${RESET_FORMAT}"
LINK=$(gcloud app browse)

LINKU=${LINK#https://}
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Creating 'details.json' with application information...${RESET_FORMAT}"
cat > details.json << EOF
{
  App name: IAP Example
  Application home page: $LINK
  Application privacy Policy link: $LINK/privacy
  Authorized domains: $LINKU
  Developer Contact Information: $EMAIL
}
EOF
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Displaying the contents of 'details.json':${RESET_FORMAT}"
cat details.json

echo
echo "${CYAN_TEXT}${BOLD_TEXT}===========================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         NOW FOLLOW VIDEO STEPS FOR FURTHER TASKS!         ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}===========================================================${RESET_FORMAT}"
echo

# Prompt for OAuth Consent Screen
while true; do
    echo "${YELLOW_TEXT}${BOLD_TEXT}Go to OAuth consent screen from here: ${RESET_FORMAT}"
    echo "${BLUE_TEXT}${BOLD_TEXT}https://console.cloud.google.com/apis/credentials/consent?project=${PROJECT_ID}${RESET_FORMAT}"
    echo
    read -p "Have you done the same as shown in the video? (Y to continue): " input
    if [[ "$input" == "Y" || "$input" == "y" ]]; then
        break
    else
        echo "❗ Please complete the same process to go next."
        echo
    fi
done

# Prompt for Identity-Aware Proxy
while true; do
    echo "${YELLOW_TEXT}${BOLD_TEXT}Go to Identity-Aware Proxy from here: ${RESET_FORMAT}"
    echo "${BLUE_TEXT}${BOLD_TEXT}https://console.cloud.google.com/security/iap?project=${PROJECT_ID}${RESET_FORMAT}"
    echo
    read -p "Have you done the same as shown in the video? (Y to continue): " input
    if [[ "$input" == "Y" || "$input" == "y" ]]; then
        break
    else
        echo "❗ Please complete the same process to go next."
        echo
    fi
done

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}               ✅ ALL TASKS COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your progress."
echo "${GREEN_TEXT}${BOLD_TEXT} If it will be not completed, try again for successfully completion of the Assessment."
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
