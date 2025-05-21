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
echo "${CYAN_TEXT}${BOLD_TEXT}         Build a Serverless App with Cloud Run that Creates PDF Files       ${RESET_FORMAT}"
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

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Disabling Cloud Run API...${RESET_FORMAT}"
gcloud services disable run.googleapis.com

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Enabling Cloud Run API...${RESET_FORMAT}"
gcloud services enable run.googleapis.com

echo
echo "${BLUE_TEXT}${BOLD_TEXT}Waiting for 30 seconds to ensure the API is fully enabled...${RESET_FORMAT}"
sleep 30

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Cloning the pet-theory repository...${RESET_FORMAT}"
git clone https://github.com/rosera/pet-theory.git

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Changing directory to lab03...${RESET_FORMAT}"
cd pet-theory/lab03

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Modifying package.json...${RESET_FORMAT}"
sed -i '6a\    "start": "node index.js",' package.json

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Installing required npm packages...${RESET_FORMAT}"
npm install express
npm install body-parser
npm install child_process
npm install @google-cloud/storage

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Building and submitting the Docker image to Google Container Registry...${RESET_FORMAT}"
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Deploying the pdf-converter service to Cloud Run...${RESET_FORMAT}"
gcloud run deploy pdf-converter \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter \
  --platform managed \
  --region $REGION \
  --no-allow-unauthenticated \
  --max-instances=1

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching the service URL...${RESET_FORMAT}"
SERVICE_URL=$(gcloud beta run services describe pdf-converter --platform managed --region $REGION --format="value(status.url)")
echo "${MAGENTA_TEXT}Service URL: ${SERVICE_URL}${RESET_FORMAT}"

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Sending a test POST request to the service...${RESET_FORMAT}"
curl -X POST $SERVICE_URL

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Sending an authenticated POST request to the service...${RESET_FORMAT}"
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" $SERVICE_URL

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating Cloud Storage buckets...${RESET_FORMAT}"
gsutil mb gs://$GOOGLE_CLOUD_PROJECT-upload
gsutil mb gs://$GOOGLE_CLOUD_PROJECT-processed

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Setting up notifications for new files in the upload bucket...${RESET_FORMAT}"
gsutil notification create -t new-doc -f json -e OBJECT_FINALIZE gs://$GOOGLE_CLOUD_PROJECT-upload

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a service account for Pub/Sub Cloud Run invoker...${RESET_FORMAT}"
gcloud iam service-accounts create pubsub-cloud-run-invoker --display-name "PubSub Cloud Run Invoker"

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Binding the service account to the Cloud Run service...${RESET_FORMAT}"
gcloud beta run services add-iam-policy-binding pdf-converter --member=serviceAccount:pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com --role=roles/run.invoker --platform managed --region $REGION

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Fetching the project number...${RESET_FORMAT}"
PROJECT_NUMBER=$(gcloud projects describe $GOOGLE_CLOUD_PROJECT --format='value(projectNumber)')

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Granting the Pub/Sub service account the necessary permissions...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com --role=roles/iam.serviceAccountTokenCreator

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a Pub/Sub subscription...${RESET_FORMAT}"
gcloud beta pubsub subscriptions create pdf-conv-sub --topic new-doc --push-endpoint=$SERVICE_URL --push-auth-service-account=pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Copying sample files to the upload bucket...${RESET_FORMAT}"
gsutil -m cp gs://spls/gsp644/* gs://$GOOGLE_CLOUD_PROJECT-upload

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the Dockerfile...${RESET_FORMAT}"
cat > Dockerfile <<EOF_END
FROM node:20
RUN apt-get update -y \
    && apt-get install -y libreoffice \
    && apt-get clean
WORKDIR /usr/src/app
COPY package.json package*.json ./
RUN npm install --only=production
COPY . .
CMD [ "npm", "start" ]
EOF_END

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating the index.js file...${RESET_FORMAT}"
cat > index.js <<'EOF_END'
const {promisify} = require('util');
const {Storage}   = require('@google-cloud/storage');
const exec        = promisify(require('child_process').exec);
const storage     = new Storage();
const express     = require('express');
const bodyParser  = require('body-parser');
const app         = express();

app.use(bodyParser.json());

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log('Listening on port', port);
});

app.post('/', async (req, res) => {
  try {
    const file = decodeBase64Json(req.body.message.data);
    await downloadFile(file.bucket, file.name);
    const pdfFileName = await convertFile(file.name);
    await uploadFile(process.env.PDF_BUCKET, pdfFileName);
    await deleteFile(file.bucket, file.name);
  }
  catch (ex) {
    console.log(`Error: ${ex}`);
  }
  res.set('Content-Type', 'text/plain');
  res.send('\n\nOK\n\n');
})

function decodeBase64Json(data) {
  return JSON.parse(Buffer.from(data, 'base64').toString());
}

async function downloadFile(bucketName, fileName) {
  const options = {destination: `/tmp/${fileName}`};
  await storage.bucket(bucketName).file(fileName).download(options);
}

async function convertFile(fileName) {
  const cmd = 'libreoffice --headless --convert-to pdf --outdir /tmp ' +
              `"/tmp/${fileName}"`;
  console.log(cmd);
  const { stdout, stderr } = await exec(cmd);
  if (stderr) {
    throw stderr;
  }
  console.log(stdout);
  pdfFileName = fileName.replace(/\.\w+$/, '.pdf');
  return pdfFileName;
}

async function deleteFile(bucketName, fileName) {
  await storage.bucket(bucketName).file(fileName).delete();
}

async function uploadFile(bucketName, fileName) {
  await storage.bucket(bucketName).upload(`/tmp/${fileName}`);
}
EOF_END

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Rebuilding and redeploying the Docker image...${RESET_FORMAT}"
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter

echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> Deploying the updated pdf-converter service...${RESET_FORMAT}"
gcloud run deploy pdf-converter \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter \
  --platform managed \
  --region $REGION \
  --memory=2Gi \
  --no-allow-unauthenticated \
  --max-instances=1 \
  --set-env-vars PDF_BUCKET=$GOOGLE_CLOUD_PROJECT-processed

echo

# ✅ Completion Message
echo
echo "${BLUE_TEXT}${BOLD_TEXT}---> 🎉===========================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}--->                ✅ ALL TASKS COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}---> 🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${BLUE_TEXT}${BOLD_TEXT}--->  ✔ Please check your progress."
echo "${BLUE_TEXT}${BOLD_TEXT}--->  If it will be not completed, try again for successfully completion of the Assessment."
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
echo "${BLUE_TEXT}${BOLD_TEXT}---> 🎉===========================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}--->           ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!          ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}---> 🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA Section
echo -e "${YELLOW_TEXT}${BOLD_TEXT}🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo ""
echo -e "${WHITE_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@techxninjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
