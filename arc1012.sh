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
echo "${CYAN_TEXT}${BOLD_TEXT}         Monitor and Manage Google Cloud Resources: Challenge Lab       ${RESET_FORMAT}"
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

# Prompt user for necessary configuration values, displaying variable names in Cyan
read -p "${CYAN_TEXT}${BOLD_TEXT}===> Enter ${CYAN_TEXT}Bucket Name${WHITE_TEXT}: ${RESET_FORMAT}" BUCKET_NAME
read -p "${CYAN_TEXT}${BOLD_TEXT}===> Enter ${CYAN_TEXT}Topic Name${WHITE_TEXT}: ${RESET_FORMAT}" TOPIC_NAME
read -p "${CYAN_TEXT}${BOLD_TEXT}===> Enter ${CYAN_TEXT}Cloud Function Name${WHITE_TEXT}: ${RESET_FORMAT}" FUNCTION_NAME
read -p "${CYAN_TEXT}${BOLD_TEXT}===> Enter ${CYAN_TEXT}Region${WHITE_TEXT}: ${RESET_FORMAT}" REGION
read -p "${CYAN_TEXT}${BOLD_TEXT}===> Enter ${CYAN_TEXT}the Username of Storage Object Viewer${WHITE_TEXT}: ${RESET_FORMAT}" BUCKET_USER
read -p "${CYAN_TEXT}${BOLD_TEXT}===> Enter your email for alert notifications (${CYAN_TEXT}ALERT_EMAIL${WHITE_TEXT}): ${RESET_FORMAT}" ALERT_EMAIL
echo

echo "${CYAN_TEXT}${BOLD_TEXT}---> ${RESET_FORMAT} Activating necessary Google Cloud services...${RESET_FORMAT}"
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  pubsub.googleapis.com
echo

echo "${CYAN_TEXT}${BOLD_TEXT}---> ${RESET_FORMAT} Configuring compute region: ${BOLD_TEXT}${WHITE_TEXT}$REGION${RESET_FORMAT}"
gcloud config set compute/region $REGION
echo

for i in {1..3}; do
        if gsutil mb -l $REGION gs://$BUCKET_NAME; then
                break # Success
        elif [ $i -eq 3 ]; then
                echo "${BOLD_TEXT}${RED_TEXT}✗ Error creating bucket after 3 attempts${RESET_FORMAT}"
                # Consider exiting here if bucket is critical: exit 1
        else
                echo "${BOLD_TEXT}${YELLOW_TEXT}⚠ Bucket creation failed, retrying in 10 seconds...${RESET_FORMAT}"
                sleep 10
        fi
done
echo

echo "${CYAN_TEXT}${BOLD_TEXT}---> ${RESET_FORMAT} Assigning storage permissions for user: ${BOLD_TEXT}${WHITE_TEXT}$BUCKET_USER${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=user:$BUCKET_USER --role=roles/storage.objectViewer

echo "${CYAN_TEXT}${BOLD_TEXT}---> ${RESET_FORMAT} Setting up Pub/Sub topic: ${BOLD_TEXT}${WHITE_TEXT}$TOPIC_NAME${RESET_FORMAT}"
gcloud pubsub topics create $TOPIC_NAME

mkdir techxninjas && cd techxninjas

echo "${CYAN_TEXT}${BOLD_TEXT}---> ${RESET_FORMAT} Generating function source files (index.js, package.json)..."
cat > index.js <<'EOF_END'
/* globals exports, require */
//jshint strict: false
//jshint esversion: 6
"use strict";
const crc32 = require("fast-crc32c");
const { Storage } = require('@google-cloud/storage');
const gcs = new Storage();
const { PubSub } = require('@google-cloud/pubsub');
const imagemagick = require("imagemagick-stream");

exports.thumbnail = (event, context) => {
  const fileName = event.name;
  const bucketName = event.bucket;
  const size = "64x64"
  const bucket = gcs.bucket(bucketName);
  const topicName = "REPLACE_WITH_YOUR_TOPIC ID";
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
};
EOF_END

sed -i "16c\  const topicName = '$TOPIC_NAME';" index.js || {
        echo "${BOLD_TEXT}${RED_TEXT}✗ Error updating topic name in index.js${RESET_FORMAT}"
        # Consider exiting: exit 1
}

cat > package.json <<'EOF_END'
{
    "name": "thumbnails",
    "version": "1.0.0",
    "description": "Create Thumbnail of uploaded image",
    "scripts": {
      "start": "node index.js"
    },
    "dependencies": {
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

export PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects list --filter="project_id:$PROJECT_ID" --format='value(project_number)')
# Get the KMS service account
SERVICE_ACCOUNT=$(gsutil kms serviceaccount -p $PROJECT_NUMBER)

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT \
  --role roles/artifactregistry.reader

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role='roles/pubsub.publisher'

echo "${YELLOW_TEXT}Waiting 30 seconds for IAM changes to propagate...${RESET_FORMAT}"

sleep 30

deploy_function() {
    gcloud functions deploy $FUNCTION_NAME \
    --gen2 \
    --runtime nodejs22 \
    --trigger-resource $BUCKET_NAME \
    --trigger-event google.storage.object.finalize \
    --entry-point thumbnail \
    --region=$REGION \
    --source . \
    --quiet
}

SERVICE_NAME="$FUNCTION_NAME"

# Loop until the Cloud Run service is created
while true; do
  # Run the deployment command
  deploy_function

  # Check if Cloud Run service is created
  if gcloud run services describe $SERVICE_NAME --region $REGION &> /dev/null; then
    echo "Cloud Run service is created..."
    break
  else
    echo "Waiting for Cloud Run service to be created..."
    sleep 20
  fi
done

wget https://storage.googleapis.com/cloud-training/arc101/travel.jpg

echo "${CYAN_TEXT}${BOLD_TEXT}---> ${RESET_FORMAT} Copying sample image to the bucket..."
# Retry loop for uploading test image
for i in {1..3}; do
        if gsutil cp travel.jpg gs://$BUCKET_NAME; then
                break # Success
        elif [ $i -eq 3 ]; then
                echo "${BOLD_TEXT}${RED_TEXT}✗ Error uploading test image after 3 attempts${RESET_FORMAT}"
                # Consider exiting: exit 1
        else
                echo "${BOLD_TEXT}${YELLOW_TEXT}⚠ Upload failed, retrying in 10 seconds...${RESET_FORMAT}"
                sleep 10
        fi
done

echo "${CYAN_TEXT}${BOLD_TEXT}---> ${RESET_FORMAT} Defining alerting policy for active function instances..."
cat > app-engine-error-percent-policy.json <<EOF_END
{
    "displayName": "Active Cloud Run Function Instances",
    "userLabels": {},
    "conditions": [
      {
        "displayName": "Cloud Function - Active instances",
        "conditionThreshold": {
          "filter": "resource.type = \"cloud_function\" AND metric.type = \"cloudfunctions.googleapis.com/function/active_instances\"",
          "aggregations": [
            {
              "alignmentPeriod": "300s",
              "crossSeriesReducer": "REDUCE_NONE",
              "perSeriesAligner": "ALIGN_MEAN"
            }
          ],
          "comparison": "COMPARISON_GT",
          "duration": "0s",
          "trigger": {
            "count": 1
          },
          "thresholdValue": 1
        }
      }
    ],
    "alertStrategy": {
      "autoClose": "604800s"
    },
    "combiner": "OR",
    "enabled": true,
    "notificationChannels": [],
    "severity": "SEVERITY_UNSPECIFIED"
  }
EOF_END

gcloud alpha monitoring policies create --policy-from-file="app-engine-error-percent-policy.json"

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
