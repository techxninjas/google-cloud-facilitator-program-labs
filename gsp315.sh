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
echo "${CYAN_TEXT}${BOLD_TEXT}      Set Up an App Dev Environment on Google Cloud: Challenge Lab     ${RESET_FORMAT}"
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
DEVSHELL_PROJECT_ID=`gcloud config get-value project`
echo ""

# 🔢 Fetching Project Number
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔍 Fetching Project Number...${RESET_FORMAT}"
export PROJECT_NUMBER=$(gcloud projects describe $DEVSHELL_PROJECT_ID --format="value(projectNumber)")
echo ""
echo ""

# 💡 Start-Up Banner
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         🚀 INITIATING THE TASK EXECUTION...          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo ""

read -p "${MAGENTA_TEXT}${BOLD_TEXT}Enter the Username 2 (Check in Left Panel of your Lab): ${RESET_FORMAT}" USER_2
export USER_2
echo

read -p "${MAGENTA_TEXT}${BOLD_TEXT}Enter the Pub/Sub Topic Name (Check in Task 2 of your Lab): ${RESET_FORMAT}" TOPIC
export TOPIC
echo

read -p "${MAGENTA_TEXT}${BOLD_TEXT}Enter the Cloud Run Function Name (Check in Task 3 of your Lab): ${RESET_FORMAT}" FUNCTION
export FUNCTION
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling required Google Cloud services...${RESET_FORMAT}"
gcloud services enable \
    artifactregistry.googleapis.com \
    cloudfunctions.googleapis.com \
    cloudbuild.googleapis.com \
    eventarc.googleapis.com \
    run.googleapis.com \
    logging.googleapis.com \
    pubsub.googleapis.com
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}---> Waiting for services to be enabled...${RESET_FORMAT}"
sleep 30

echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching project number...${RESET_FORMAT}"
PROJECT_NUMBER=$(gcloud projects describe $DEVSHELL_PROJECT_ID --format='value(projectNumber)')
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Adding IAM policy bindings for Eventarc...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
    --role=roles/eventarc.eventReceiver
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}---> Waiting for IAM policy binding to take effect...${RESET_FORMAT}"
sleep 20
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching service account for KMS...${RESET_FORMAT}"
SERVICE_ACCOUNT="$(gsutil kms serviceaccount -p $DEVSHELL_PROJECT_ID)"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Adding IAM policy bindings for Pub/Sub publisher...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role='roles/pubsub.publisher'
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}---> Waiting for IAM policy binding to take effect...${RESET_FORMAT}"
sleep 20
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Adding IAM policy bindings for Service Account Token Creator...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
        --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com \
        --role=roles/iam.serviceAccountTokenCreator
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}---> Waiting for IAM policy binding to take effect...${RESET_FORMAT}"
sleep 20
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a Cloud Storage bucket...${RESET_FORMAT}"
gsutil mb -l $REGION gs://$DEVSHELL_PROJECT_ID-bucket
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Pub/Sub topic: $TOPIC...${RESET_FORMAT}"
gcloud pubsub topics create $TOPIC
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting up the Cloud Function code...${RESET_FORMAT}"
mkdir lol
cd lol
echo

cat > index.js <<'EOF_END'
const functions = require('@google-cloud/functions-framework');
const crc32 = require("fast-crc32c");
const { Storage } = require('@google-cloud/storage');
const gcs = new Storage();
const { PubSub } = require('@google-cloud/pubsub');
const imagemagick = require("imagemagick-stream");

functions.cloudEvent('$FUNCTION_NAME', cloudEvent => {
    const event = cloudEvent.data;

    console.log(`Event: ${event}`);
    console.log(`Hello ${event.bucket}`);

    const fileName = event.name;
    const bucketName = event.bucket;
    const size = "64x64"
    const bucket = gcs.bucket(bucketName);
    const topicName = "$TOPIC_NAME";
    const pubsub = new PubSub();
    if ( fileName.search("64x64_thumbnail") == -1 ){
        // doesn't have a thumbnail, get the filename extension
        var filename_split = fileName.split('.');
        var filename_ext = filename_split[filename_split.length - 1];
        var filename_without_ext = fileName.substring(0, fileName.length - filename_ext.length );
        if (filename_ext.toLowerCase() == 'png' || filename_ext.toLowerCase() == 'jpg'){
            // only support png and jpg at this point
            console.log(`Processing Original: gs://${bucketName}/${fileName}`);
            const gcsObject = bucket.file(fileName);
            let newFilename = filename_without_ext + size + '_thumbnail.' + filename_ext;
            let gcsNewObject = bucket.file(newFilename);
            let srcStream = gcsObject.createReadStream();
            let dstStream = gcsNewObject.createWriteStream();
            let resize = imagemagick().resize(size).quality(90);
            srcStream.pipe(resize).pipe(dstStream);
            return new Promise((resolve, reject) => {
                dstStream
                    .on("error", (err) => {
                        console.log(`Error: ${err}`);
                        reject(err);
                    })
                    .on("finish", () => {
                        console.log(`Success: ${fileName} → ${newFilename}`);
                            // set the content-type
                            gcsNewObject.setMetadata(
                            {
                                contentType: 'image/'+ filename_ext.toLowerCase()
                            }, function(err, apiResponse) {});
                            pubsub
                                .topic(topicName)
                                .publisher()
                                .publish(Buffer.from(newFilename))
                                .then(messageId => {
                                    console.log(`Message ${messageId} published.`);
                                })
                                .catch(err => {
                                    console.error('ERROR:', err);
                                });
                    });
            });
        }
        else {
            console.log(`gs://${bucketName}/${fileName} is not an image I can handle`);
        }
    }
    else {
        console.log(`gs://${bucketName}/${fileName} already has a thumbnail`);
    }
});
EOF_END

sed -i "8c\functions.cloudEvent('$FUNCTION', cloudEvent => { " index.js

sed -i "18c\  const topicName = '$TOPIC';" index.js

cat > package.json <<EOF_END
{
        "name": "thumbnails",
        "version": "1.0.0",
        "description": "Create Thumbnail of uploaded image",
        "scripts": {
            "start": "node index.js"
        },
        "dependencies": {
            "@google-cloud/functions-framework": "^3.0.0",
            "@google-cloud/pubsub": "^2.0.0",
            "@google-cloud/storage": "^5.0.0",
            "fast-crc32c": "1.0.4",
            "imagemagick-stream": "4.1.1"
        },
        "devDependencies": {},
        "engines": {
            "node": ">=4.3.2"
        }
    }
EOF_END

PROJECT_ID=$(gcloud config get-value project)
BUCKET_SERVICE_ACCOUNT="${PROJECT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Adding IAM policy bindings for Pub/Sub publisher...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$BUCKET_SERVICE_ACCOUNT \
    --role=roles/pubsub.publisher
echo

# Your existing deployment command
deploy_function() {
        echo "${BLUE_TEXT}${BOLD_TEXT}---> Deploying Cloud Function: $FUNCTION...${RESET_FORMAT}"
        gcloud functions deploy $FUNCTION \
        --gen2 \
        --runtime nodejs20 \
        --trigger-resource $DEVSHELL_PROJECT_ID-bucket \
        --trigger-event google.storage.object.finalize \
        --entry-point $FUNCTION \
        --region=$REGION \
        --source . \
        --quiet
}
echo

# Variables
SERVICE_NAME="$FUNCTION"
echo

# Loop until the Cloud Run service is created
while true; do
    # Run the deployment command
    deploy_function

    # Check if Cloud Run service is created
    if gcloud run services describe $SERVICE_NAME --region $REGION &> /dev/null; then
        echo "${GREEN_TEXT}${BOLD_TEXT}Cloud Run service is created. Exiting the loop.${RESET_FORMAT}"
        break
    else
        echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for Cloud Run service to be created...${RESET_FORMAT}"
        sleep 20
    fi
done
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Downloading sample image...${RESET_FORMAT}"
curl -o map.jpg https://storage.googleapis.com/cloud-training/gsp315/map.jpg
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Uploading sample image to Cloud Storage bucket...${RESET_FORMAT}"
gsutil cp map.jpg gs://$DEVSHELL_PROJECT_ID-bucket/map.jpg
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Removing IAM policy binding for user: $USER_2...${RESET_FORMAT}"
gcloud projects remove-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member=user:$USER_2 \
  --role=roles/viewer
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
