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
echo "${CYAN_TEXT}${BOLD_TEXT}         Prepare Data for ML APIs on Google Cloud: Challenge Lab       ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-----------------------------------------------------------------------${RESET_FORMAT}"
echo ""

# 💡 Start-Up Banner
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         🚀 INITIATING THE TASK EXECUTION...          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo ""

# Function to get input from the user with different colors
get_input() {
    local prompt="$1"
    local var_name="$2"
    local color_index="$3"

    echo -n -e "${BOLD_TEXT}${COLORS[$color_index]}${prompt}${RESET_FORMAT}"
    read input
    export "$var_name"="$input"
}

# Gather inputs for the required variables, cycling through colors
get_input "Enter the DATASET value:" "DATASET" 0
get_input "Enter the BUCKET value:" "BUCKET" 1
get_input "Enter the TABLE value:" "TABLE" 2
get_input "Enter the BUCKET_URL_1 value:" "BUCKET_URL_1" 3
get_input "Enter the BUCKET_URL_2 value:" "BUCKET_URL_2" 4

echo

# Step 1: Enable API keys service
echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling API keys service...${RESET_FORMAT}"
gcloud services enable apikeys.googleapis.com
echo

# Step 2: Create an API key
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating an API key with display name 'awesome'...${RESET_FORMAT}"
gcloud alpha services api-keys create --display-name="awesome" 
echo

# Step 3: Retrieve API key name
echo "${BLUE_TEXT}${BOLD_TEXT}---> Retrieving API key name...${RESET_FORMAT}"
KEY_NAME=$(gcloud alpha services api-keys list --format="value(name)" --filter "displayName=awesome")
echo

# Step 4: Get API key string
echo "${BLUE_TEXT}${BOLD_TEXT}---> Getting API key string...${RESET_FORMAT}"
API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME --format="value(keyString)")
echo

# Step 5: Get default Google Cloud region
echo "${BLUE_TEXT}${BOLD_TEXT}---> Getting default Google Cloud region...${RESET_FORMAT}"
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")
echo

# Step 6: Retrieve project ID
echo "${BLUE_TEXT}${BOLD_TEXT}---> Retrieving project ID...${RESET_FORMAT}"
PROJECT_ID=$(gcloud config get-value project)
echo

# Step 7: Retrieve project number
echo "${BLUE_TEXT}${BOLD_TEXT}---> Retrieving project number...${RESET_FORMAT}"
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="json" | jq -r '.projectNumber')
echo

# Step 8: Create BigQuery dataset
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating BigQuery dataset...${RESET_FORMAT}"
bq mk $DATASET
echo

# Step 9: Create Cloud Storage bucket
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Cloud Storage bucket...${RESET_FORMAT}"
gsutil mb gs://$BUCKET
echo

# Step 10: Copy lab files from GCS
echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying lab files from GCS...${RESET_FORMAT}"
gsutil cp gs://cloud-training/gsp323/lab.csv  .
gsutil cp gs://cloud-training/gsp323/lab.schema .
echo

# Step 11: Display schema contents
echo "${BLUE_TEXT}${BOLD_TEXT}---> Displaying schema contents...${RESET_FORMAT}"
cat lab.schema

echo '[
    {"type":"STRING","name":"guid"},
    {"type":"BOOLEAN","name":"isActive"},
    {"type":"STRING","name":"firstname"},
    {"type":"STRING","name":"surname"},
    {"type":"STRING","name":"company"},
    {"type":"STRING","name":"email"},
    {"type":"STRING","name":"phone"},
    {"type":"STRING","name":"address"},
    {"type":"STRING","name":"about"},
    {"type":"TIMESTAMP","name":"registered"},
    {"type":"FLOAT","name":"latitude"},
    {"type":"FLOAT","name":"longitude"}
]' > lab.schema

# Step 12: Create BigQuery table
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating BigQuery table...${RESET_FORMAT}"
bq mk --table $DATASET.$TABLE lab.schema
echo

# Step 13: Run Dataflow job to load data into BigQuery
echo "${BLUE_TEXT}${BOLD_TEXT}---> Running Dataflow job to load data into BigQuery...${RESET_FORMAT}"
gcloud dataflow jobs run awesome-jobs --gcs-location gs://dataflow-templates-$REGION/latest/GCS_Text_to_BigQuery --region $REGION --worker-machine-type e2-standard-2 --staging-location gs://$DEVSHELL_PROJECT_ID-marking/temp --parameters inputFilePattern=gs://cloud-training/gsp323/lab.csv,JSONPath=gs://cloud-training/gsp323/lab.schema,outputTable=$DEVSHELL_PROJECT_ID:$DATASET.$TABLE,bigQueryLoadingTemporaryDirectory=gs://$DEVSHELL_PROJECT_ID-marking/bigquery_temp,javascriptTextTransformGcsPath=gs://cloud-training/gsp323/lab.js,javascriptTextTransformFunctionName=transform
echo

# Step 14: Grant IAM roles to service account
echo "${BLUE_TEXT}${BOLD_TEXT}---> Granting IAM roles to service account...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member "serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
    --role "roles/storage.admin"
echo

# Step 15: Assign IAM roles to user
echo "${BLUE_TEXT}${BOLD_TEXT}---> Assigning roles to user...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member=user:$USER_EMAIL \
  --role=roles/dataproc.editor
echo

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member=user:$USER_EMAIL \
  --role=roles/storage.objectViewer
echo

# Step 16: Update VPC subnet for private IP access
echo "${BLUE_TEXT}${BOLD_TEXT}---> Updating VPC subnet for private IP access...${RESET_FORMAT}"
gcloud compute networks subnets update default \
    --region $REGION \
    --enable-private-ip-google-access
echo

# Step 17: Create a service account
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a service account...${RESET_FORMAT}"
gcloud iam service-accounts create awesome \
  --display-name "my natural language service account"
echo

sleep 15
echo

# Step 18: Generate service account key
echo "${BLUE_TEXT}${BOLD_TEXT}---> Generating service account key...${RESET_FORMAT}"
gcloud iam service-accounts keys create ~/key.json \
  --iam-account awesome@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
echo

sleep 15
echo

# Step 19: Activate service account
echo "${BLUE_TEXT}${BOLD_TEXT}---> Activating service account...${RESET_FORMAT}"
export GOOGLE_APPLICATION_CREDENTIALS="/home/$USER/key.json"
echo

sleep 30
echo

gcloud auth activate-service-account awesome@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --key-file=$GOOGLE_APPLICATION_CREDENTIALS
echo

# Step 20: Run ML entity analysis
echo "${BLUE_TEXT}${BOLD_TEXT}---> Running ML entity analysis...${RESET_FORMAT}"
gcloud ml language analyze-entities --content="Old Norse texts portray Odin as one-eyed and long-bearded, frequently wielding a spear named Gungnir and wearing a cloak and a broad hat." > result.json
echo

# Step 21: Authenticate to Google Cloud without launching a browser
echo "${BLUE_TEXT}${BOLD_TEXT}---> Authenticating to Google Cloud...${RESET_FORMAT}"
echo
gcloud auth login --no-launch-browser --quiet
echo

# Step 22: Copy result to bucket
echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying result to bucket...${RESET_FORMAT}"
gsutil cp result.json $BUCKET_URL_2

cat > request.json <<EOF
{
  "config": {
      "encoding":"FLAC",
      "languageCode": "en-US"
  },
  "audio": {
      "uri":"gs://cloud-training/gsp323/task3.flac"
  }
}
EOF
echo

# Step 23: Perform speech recognition using Google Cloud Speech-to-Text API
echo "${BLUE_TEXT}${BOLD_TEXT}---> Performing speech recognition...${RESET_FORMAT}"
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json
echo

# Step 24: Copy the speech recognition result to a Cloud Storage bucket
echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying speech recognition result to Cloud Storage...${RESET_FORMAT}"
gsutil cp result.json $BUCKET_URL_1
echo

# Step 25: Create a new service account named 'quickstart'
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating new service account 'quickstart'...${RESET_FORMAT}"
gcloud iam service-accounts create quickstart
echo

sleep 15

# Step 26: Create a service account key for 'quickstart'
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating service account key...${RESET_FORMAT}"
gcloud iam service-accounts keys create key.json --iam-account quickstart@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
echo

sleep 15

# Step 27: Authenticate using the created service account key
echo "${BLUE_TEXT}${BOLD_TEXT}---> Activating service account...${RESET_FORMAT}"
gcloud auth activate-service-account --key-file key.json
echo

# Step 28: Create a request JSON file for Video Intelligence API
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating request JSON file for Video Intelligence API...${RESET_FORMAT}"
cat > request.json <<EOF 
{
   "inputUri":"gs://spls/gsp154/video/train.mp4",
   "features": [
       "TEXT_DETECTION"
   ]
}
EOF
echo

# Step 29: Annotate the video using Google Cloud Video Intelligence API
echo "${BLUE_TEXT}${BOLD_TEXT}---> Sending video annotation request...${RESET_FORMAT}"
curl -s -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    'https://videointelligence.googleapis.com/v1/videos:annotate' \
    -d @request.json
echo

# Step 30: Retrieve the results of the video annotation
echo "${BLUE_TEXT}${BOLD_TEXT}---> Retrieving video annotation results...${RESET_FORMAT}"
curl -s -H 'Content-Type: application/json' -H "Authorization: Bearer $ACCESS_TOKEN" 'https://videointelligence.googleapis.com/v1/operations/OPERATION_FROM_PREVIOUS_REQUEST' > result1.json

sleep 30
echo

# Step 31: Perform speech recognition again
echo "${BLUE_TEXT}${BOLD_TEXT}---> Performing speech recognition again...${RESET_FORMAT}"
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json
echo

# Step 32: Annotate the video again using Google Cloud Video Intelligence API
echo "${BLUE_TEXT}${BOLD_TEXT}---> Sending another video annotation request...${RESET_FORMAT}"
curl -s -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    'https://videointelligence.googleapis.com/v1/videos:annotate' \
    -d @request.json
echo

# Step 33: Retrieve the new video annotation results
echo "${BLUE_TEXT}${BOLD_TEXT}---> Retrieving new video annotation results...${RESET_FORMAT}"
curl -s -H 'Content-Type: application/json' -H "Authorization: Bearer $ACCESS_TOKEN" 'https://videointelligence.googleapis.com/v1/operations/OPERATION_FROM_PREVIOUS_REQUEST' > result1.json
echo

# Function to prompt user to check their progress
function check_progress {
    while true; do
        echo
        echo -n "${YELLOW_TEXT}${BOLD_TEXT}Have you checked your progress for Task 1, 3 & 4? (Y/N): ${RESET_FORMAT}"
        read -r user_input
        if [[ "$user_input" == "Y" || "$user_input" == "y" ]]; then
            echo
            echo "${BOLD_TEXT}${GREEN_TEXT}Great! Proceeding to the next steps...${RESET_FORMAT}"
            echo
            break
        elif [[ "$user_input" == "N" || "$user_input" == "n" ]]; then
            echo
            echo "${BOLD_TEXT}${RED_TEXT}Please check your progress for Task 1, 3 & 4 and then press Y to continue.${RESET_FORMAT}"
        else
            echo
            echo "${BOLD_TEXT}${RED_TEXT}Invalid input. Please enter Y or N.${RESET_FORMAT}"
        fi
    done
}
echo

# Call function to check progress before proceeding
check_progress

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}          ✅ TASK 1, 3 and 4 COMPLETED SUCCESSFULLY!         ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Run next command for Task 2."
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
