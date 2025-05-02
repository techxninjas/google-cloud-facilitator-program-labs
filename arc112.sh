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
echo "${CYAN_TEXT}${BOLD_TEXT}                 App Engine: 3 Ways: Challenge Lab                     ${RESET_FORMAT}"
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

# 💡 Start-Up Banner
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         🚀 INITIATING THE TASK EXECUTION...          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo ""

# Function to prompt and export MESSAGE
select_message() {
  echo ""
  echo -e "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔍 Fetching Pre-Requisuites...${RESET_FORMAT}"
  echo ""
  echo "Choose which message was given in your Task 4. Kindly check your lab and enter the option and hit Enter:"
  echo "A: \"Welcome to this world!\""
  echo "B: \"Hello, Cruel World!\""
  echo "C: \"Goodbye World!\""
  read -p "Enter your option (A/B/C): " option

  # Convert to lowercase
  option=$(echo "$option" | tr '[:upper:]' '[:lower:]')

  case "$option" in
    a)
      export MESSAGE="Welcome to this world!"
      ;;
    b)
      export MESSAGE="Hello, Cruel World!"
      ;;
    c)
      export MESSAGE="Goodbye World!"
      ;;
    *)
      echo -e "${RED_TEXT}❗ Please provide the correct option (A, B, or C).${RESET_FORMAT}"
      select_message  # Recursively call until valid input
      ;;
  esac
}

# Start selection
select_message

# For debugging/confirmation
echo ""
echo "✅ Your lab's MESSAGE is: \"$MESSAGE\""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling the App Engine API${RESET_FORMAT}"
gcloud services enable appengine.googleapis.com
sleep 20
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> SSH into the lab-setup instance and enable the App Engine API${RESET_FORMAT}"
gcloud compute ssh --zone "$ZONE" "lab-setup" --project "$DEVSHELL_PROJECT_ID" --quiet --command "gcloud services enable appengine.googleapis.com && git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git"
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Cloning the sample repository${RESET_FORMAT}"
git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Navigating to the hello_world directory${RESET_FORMAT}"
cd python-docs-samples/appengine/standard_python3/hello_world
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Updating the main.py file with the message${RESET_FORMAT}"
sed -i "32c\    return \"$MESSAGE\"" main.py
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the App Engine app with specified service account and region${RESET_FORMAT}"
gcloud app create --service-account=$DEVSHELL_PROJECT_ID@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --region=$REGION
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> Deploying the App Engine app${RESET_FORMAT}"
gcloud app deploy --quiet
echo ""

echo "${BLUE_TEXT}${BOLD_TEXT}---> SSH into the lab-setup instance again${RESET_FORMAT}"
gcloud compute ssh --zone "$ZONE" "lab-setup" --project "$DEVSHELL_PROJECT_ID" --quiet --command "gcloud services enable appengine.googleapis.com && git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git"
echo ""

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
echo -e "${WHITE_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
