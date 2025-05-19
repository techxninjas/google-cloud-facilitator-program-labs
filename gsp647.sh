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
echo "${CYAN_TEXT}${BOLD_TEXT}                  Configuring IAM Permissions with gcloud          ${RESET_FORMAT}"
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

echo "${BLUE_TEXT}${BOLD_TEXT}---> Authenticating your Google Cloud account... Please follow the prompts.${RESET_FORMAT}"
gcloud auth login --quiet

echo "${GREEN_TEXT}${BOLD_TEXT}✅ Default Zone set to: ${ZONE}${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Default Region set to: ${REGION}${RESET_FORMAT}"

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the first VM instance named 'lab-1'...${RESET_FORMAT}"
gcloud compute instances create lab-1 --zone $ZONE --machine-type=e2-standard-2

echo "${BLUE_TEXT}${BOLD_TEXT}---> Selecting an alternative zone within the same region (${REGION})...${RESET_FORMAT}"
export NEWZONE=$(gcloud compute zones list --filter="name~'^$REGION'" \
  --format="value(name)" | grep -v "^$ZONE$" | head -n 1)
echo "${GREEN_TEXT}${BOLD_TEXT}✅ New Zone selected: ${NEWZONE}${RESET_FORMAT}"

echo "${BLUE_TEXT}${BOLD_TEXT}---> Updating gcloud configuration to use the new zone (${NEWZONE})...${RESET_FORMAT}"
gcloud config set compute/zone $NEWZONE

# Function to prompt user to check their progress
function check_progress {
    while true; do
        echo
        echo -n "${YELLOW_TEXT}${BOLD_TEXT}Have you checked your progress for Task 1? (Y/N): ${RESET_FORMAT}"
        read -r user_input
        if [[ "$user_input" == "Y" || "$user_input" == "y" ]]; then
            echo
            echo "${GREEN_TEXT}${BOLD_TEXT}Awesome! Moving on to the next steps...${RESET_FORMAT}"
            echo
            break
        elif [[ "$user_input" == "N" || "$user_input" == "n" ]]; then
            echo
            echo "${RED_TEXT}${BOLD_TEXT}Please check Task 1 progress. Enter Y when ready to continue.${RESET_FORMAT}"
        else
            echo
            echo "${RED_TEXT}${BOLD_TEXT}Invalid input. Please enter Y or N.${RESET_FORMAT}"
        fi
    done
}

echo
echo "${CYAN_TEXT}${BOLD_TEXT}========================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}      CHECK PROGRESS OF TASK 1 FOR FURTHER TASKS      ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}========================================================${RESET_FORMAT}"
echo

# Call function to check progress before proceeding
check_progress

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a new gcloud configuration named 'user2'...${RESET_FORMAT}"
gcloud config configurations create user2 --quiet

echo "${BLUE_TEXT}${BOLD_TEXT}---> Authenticating as 'user2'... Please follow the prompts (no browser will launch).${RESET_FORMAT}"
gcloud auth login --no-launch-browser --quiet

echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting up project, zone, and region for the 'user2' configuration based on the default settings...${RESET_FORMAT}"
gcloud config set project $(gcloud config get-value project --configuration=default) --configuration=user2
gcloud config set compute/zone $(gcloud config get-value compute/zone --configuration=default) --configuration=user2
gcloud config set compute/region $(gcloud config get-value compute/region --configuration=default) --configuration=user2
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Switching back to the 'default' gcloud configuration...${RESET_FORMAT}"
gcloud config configurations activate default
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Installing necessary packages: epel-release and jq...${RESET_FORMAT}"
sudo yum -y install epel-release
sudo yum -y install jq
echo

echo "${CYAN_TEXT}${BOLD_TEXT}---> Please provide the following details:${RESET_FORMAT}"
echo
get_and_export_values() {
echo -n "${BLUE_TEXT}${BOLD_TEXT}---> ---> Enter the USERID2 (Username 2): ${RESET_FORMAT}"
read USERID2
echo

echo -n "${BLUE_TEXT}${BOLD_TEXT}---> ---> Enter the PROJECTID2: ${RESET_FORMAT}"
read PROJECTID2
echo

echo -n "${BLUE_TEXT}${BOLD_TEXT}---> ---> Enter the ZONE2: ${RESET_FORMAT}"
read ZONE2
echo

# Export the values in the current session
export PROJECTID2
export USERID2
export ZONE2

# Append the export statements to ~/.bashrc with actual values
echo "export PROJECTID2=$PROJECTID2" >> ~/.bashrc
echo "export USERID2=$USERID2" >> ~/.bashrc
echo "export ZONE2=$ZONE2" >> ~/.bashrc
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Values exported and saved to ~/.bashrc.${RESET_FORMAT}"
}
get_and_export_values
echo

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Granting the 'Viewer' role to ${USERID2} on project ${PROJECTID2}...${RESET_FORMAT}"
. ~/.bashrc # Source bashrc to load the new variables
gcloud projects add-iam-policy-binding $PROJECTID2 --member user:$USERID2 --role=roles/viewer
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Switching gcloud configuration to 'user2'...${RESET_FORMAT}"
gcloud config configurations activate user2
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting the active project for 'user2' configuration to ${PROJECTID2}...${RESET_FORMAT}"
gcloud config set project $PROJECTID2
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Switching back to the 'default' gcloud configuration again...${RESET_FORMAT}"
gcloud config configurations activate default
echo

echo "${CYAN_TEXT}${BOLD_TEXT}---> Creating a custom IAM role named 'devops' in project ${PROJECTID2} with specific compute permissions...${RESET_FORMAT}"
gcloud iam roles create devops --project $PROJECTID2 --permissions "compute.instances.create,compute.instances.delete,compute.instances.start,compute.instances.stop,compute.instances.update,compute.disks.create,compute.subnetworks.use,compute.subnetworks.useExternalIp,compute.instances.setMetadata,compute.instances.setServiceAccount"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Assigning necessary IAM roles (Service Account User and custom 'devops') to ${USERID2} on project ${PROJECTID2}...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $PROJECTID2 --member user:$USERID2 --role=roles/iam.serviceAccountUser
echo

gcloud projects add-iam-policy-binding $PROJECTID2 --member user:$USERID2 --role=projects/$PROJECTID2/roles/devops
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> ---> Switching gcloud configuration back to 'user2'...${RESET_FORMAT}"
gcloud config configurations activate user2
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the second VM instance named 'lab-2' in zone ${ZONE2} as 'user2'...${RESET_FORMAT}"
gcloud compute instances create lab-2 --zone $ZONE2 --machine-type=e2-standard-2
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Switching back to the 'default' gcloud configuration one last time...${RESET_FORMAT}"
gcloud config configurations activate default
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting the active project for the 'default' configuration to ${PROJECTID2}...${RESET_FORMAT}"
gcloud config set project $PROJECTID2
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a new service account named 'devops'...${RESET_FORMAT}"
gcloud iam service-accounts create devops --display-name devops
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Retrieving the email address of the newly created 'devops' service account...${RESET_FORMAT}"
SA=$(gcloud iam service-accounts list --filter="displayName='devops'" --format="value(email)")
if [ -z "$SA" ]; then
  echo -e "${RED_TEXT}${BOLD_TEXT}❌ Failed to retrieve service account email.${RESET_FORMAT}"
  echo -e "${RED_TEXT}${BOLD_TEXT}🔎 Please check your lab and enter the service account email manually (e.g., devops@<project-id>.iam.gserviceaccount.com):${RESET_FORMAT}"
  read -p "👉 Enter service account email: " SA
else
  echo -e "${GREEN_TEXT}${BOLD_TEXT}✅ Service Account Email: $SA${RESET_FORMAT}"
fi
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Granting IAM roles (Service Account User and Compute Instance Admin) to the 'devops' service account (${SA})...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $PROJECTID2 --member serviceAccount:$SA --role=roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding $PROJECTID2 --member serviceAccount:$SA --role=roles/compute.instanceAdmin

echo "${MAGENTA_TEXT}${BOLD_TEXT}---> Creating the third VM instance named 'lab-3' using the 'devops' service account in zone ${ZONE2}...${RESET_FORMAT}"
gcloud compute instances create lab-3 --zone $ZONE2 --machine-type=e2-standard-2 --service-account $SA --scopes "https://www.googleapis.com/auth/compute"

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
