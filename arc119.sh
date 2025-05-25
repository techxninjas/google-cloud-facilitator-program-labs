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
echo "${CYAN_TEXT}${BOLD_TEXT}         LAB_NAME       ${RESET_FORMAT}"
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

echo ""
echo "${YELLOW_TEXT}${BOLD_TEXT}Please check your lab task allotment and select the corresponding option:${RESET_FORMAT}"
echo ""
echo "${WHITE_TEXT}${BOLD_TEXT}Dynamic Allocation 1:${RESET_FORMAT}"
echo "---> Task 1: Create a Cloud Storage bucket."
echo "---> Task 2: Create a lake in Dataplex and add a zone to your lake."
echo ""
echo "${WHITE_TEXT}${BOLD_TEXT}Dynamic Allocation 2:${RESET_FORMAT}"
echo "---> Task 1: Create a BigQuery dataset."
echo "---> Task 2: Add a zone to your lake."
echo ""
echo "${WHITE_TEXT}${BOLD_TEXT}Dynamic Allocation 3:${RESET_FORMAT}"
echo "---> Task 1: Create a lake in Dataplex and add a zone to your lake."
echo "---> Task 2: Attach an existing Cloud Storage bucket to the zone."
echo ""
echo "${WHITE_TEXT}${BOLD_TEXT}Dynamic Allocation 4:${RESET_FORMAT}"
echo "---> Task 1: Create a lake in Dataplex and add a zone to your lake."
echo "---> Task 2: Environment Creation for Dataplex."
echo ""

read -p "$(echo -e "${CYAN_TEXT}${BOLD_TEXT}Enter your allocation choice (A/a, B/b, C/c, D/d): ${RESET_FORMAT}")" choice

case "${choice,,}" in
    a)
        echo "${GREEN_TEXT}Executing Dynamic Allocation 1 tasks...${RESET_FORMAT}"
        export KEY_1=domain_type
        export VALUE_1=source_data
        echo
        
        gsutil mb -p $DEVSHELL_PROJECT_ID -l $REGION -b on gs://$DEVSHELL_PROJECT_ID-bucket/
        echo
        
        gcloud alpha dataplex lakes create customer-lake \
        --display-name="Customer-Lake" \
         --location=$REGION \
         --labels="key_1=$KEY_1,value_1=$VALUE_1"
        echo
        
        gcloud dataplex zones create public-zone \
            --lake=customer-lake \
            --location=$REGION \
            --type=RAW \
            --resource-location-type=SINGLE_REGION \
            --display-name="Public-Zone"
        echo
        
        gcloud dataplex environments create dataplex-lake-env \
                   --project=$DEVSHELL_PROJECT_ID --location=$REGION --lake=customer-lake \
                   --os-image-version=1.0 --compute-node-count 3  --compute-max-node-count 3
        echo
        
        gcloud data-catalog tag-templates create customer_data_tag_template \
            --location=$REGION \
            --display-name="Customer Data Tag Template" \
            --field=id=data_owner,display-name="Data Owner",type=string,required=TRUE \
            --field=id=pii_data,display-name="PII Data",type='enum(Yes|No)',required=TRUE
        echo
        ;;
    b)
        echo "${GREEN_TEXT}Executing Dynamic Allocation 2 tasks...${RESET_FORMAT}"
        bq mk --location=US Raw_data
        echo

        bq load --source_format=AVRO Raw_data.public-data gs://spls/gsp1145/users.avro
        echo

        gcloud dataplex zones create temperature-raw-data \
            --lake=public-lake \
            --location=$REGION \
            --type=RAW \
            --resource-location-type=SINGLE_REGION \
            --display-name="temperature-raw-data"
        echo

        gcloud dataplex assets create customer-details-dataset \
            --location=$REGION \
            --lake=public-lake \
            --zone=temperature-raw-data \
            --resource-type=BIGQUERY_DATASET \
            --resource-name=projects/$DEVSHELL_PROJECT_ID/datasets/customer_reference_data \
            --display-name="Customer Details Dataset" \
            --discovery-enabled
        echo

        gcloud data-catalog tag-templates create protected_data_template \
            --location=$REGION \
            --display-name="Protected Data Template" \
            --field=id=protected_data_flag,display-name="Protected Data Flag",type='enum(Yes|No)',required=TRUE
        echo

        echo "${CYAN}${BOLD}Click here: "${RESET}""${BLUE}${BOLD}"https://console.cloud.google.com/dataplex/search?project=$DEVSHELL_PROJECT_ID&q=us-states&qSystems=BIGQUERY""${RESET}"
        sleep 20
        ;;
    c)
        echo "${GREEN_TEXT}Executing Dynamic Allocation 3 tasks...${RESET_FORMAT}"
        gcloud alpha dataplex lakes create customer-lake \
        --display-name="Customer-Lake" \
         --location=$REGION \
         --labels="key_1=$KEY_1,value_1=$VALUE_1"
        echo

        gcloud dataplex zones create public-zone \
            --lake=customer-lake \
            --location=$REGION \
            --type=RAW \
            --resource-location-type=SINGLE_REGION \
            --display-name="Public-Zone"
        echo

        gcloud dataplex assets create customer-raw-data --location=$REGION \
                    --lake=customer-lake --zone=public-zone \
                    --resource-type=STORAGE_BUCKET \
                    --resource-name=projects/$DEVSHELL_PROJECT_ID/buckets/$DEVSHELL_PROJECT_ID-customer-bucket \
                    --discovery-enabled \
                    --display-name="Customer Raw Data"
        echo
        
        gcloud dataplex assets create customer-reference-data --location=$REGION \
                    --lake=customer-lake --zone=public-zone \
                    --resource-type=BIGQUERY_DATASET \
                    --resource-name=projects/$DEVSHELL_PROJECT_ID/datasets/customer_reference_data \
                    --display-name="Customer Reference Data"
        echo

        echo "${CYAN}${BOLD}Click here: "${RESET}""${BLUE}${BOLD}"https://console.cloud.google.com/dataplex/lakes/customer-lake/zones/public-zone/create-entity;location=$REGION?project=$DEVSHELL_PROJECT_ID""${RESET}"
        sleep 20
        ;;
    d)
        echo "${GREEN_TEXT}Executing Dynamic Allocation 4 tasks...${RESET_FORMAT}"
        export KEY_1=domain_type
        export VALUE_1=source_data
        
        gcloud alpha dataplex lakes create customer-lake \
        --display-name="Customer-Lake" \
         --location=$REGION \
         --labels="key_1=$KEY_1,value_1=$VALUE_1"
        echo
        
        gcloud dataplex zones create public-zone \
            --lake=customer-lake \
            --location=$REGION \
            --type=RAW \
            --resource-location-type=SINGLE_REGION \
            --display-name="Public-Zone"
        echo
        
        gcloud dataplex environments create dataplex-lake-env \
                   --project=$DEVSHELL_PROJECT_ID --location=$REGION --lake=customer-lake \
                   --os-image-version=1.0 --compute-node-count 3  --compute-max-node-count 3
        echo
        
        gcloud dataplex assets create customer-raw-data --location=$REGION \
                    --lake=customer-lake --zone=public-zone \
                    --resource-type=STORAGE_BUCKET \
                    --resource-name=projects/$DEVSHELL_PROJECT_ID/buckets/$DEVSHELL_PROJECT_ID-customer-bucket \
                    --discovery-enabled \
                    --display-name="Customer Raw Data"
        echo
        
        gcloud dataplex assets create customer-reference-data --location=$REGION \
                    --lake=customer-lake --zone=public-zone \
                    --resource-type=BIGQUERY_DATASET \
                    --resource-name=projects/$DEVSHELL_PROJECT_ID/datasets/customer_reference_data \
                    --display-name="Customer Reference Data"
        echo
        
        gcloud data-catalog tag-templates create customer_data_tag_template \
            --location=$REGION \
            --display-name="Customer Data Tag Template" \
            --field=id=data_owner,display-name="Data Owner",type=string,required=TRUE \
            --field=id=pii_data,display-name="PII Data",type='enum(Yes|No)',required=TRUE
        echo
        ;;
    *)
        echo "${RED_TEXT}Invalid choice! Please run the script again and enter A, B, C, or D.${RESET_FORMAT}"
        exit 1
        ;;
esac

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
