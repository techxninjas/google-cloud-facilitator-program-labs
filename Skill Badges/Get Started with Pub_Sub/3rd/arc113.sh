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

# 🚨 Welcome Message
echo "${CYAN_TEXT}${BOLD}🚀===========================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}        3rd Lab: Get Started with Pub/Sub: Challenge Lab      ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}           2nd Skill Badge: Get Started with Pub/Sub          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD}===========================================================🚀${RESET_FORMAT}"
echo ""

# 🚀 Task Execution Init
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}         🚀 INITIATING THE TASK EXECUTION...          ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

# 📌 Prompt for Task Selection
while true; do
  echo "${YELLOW_TEXT}${BOLD_TEXT}Please select the task from the options below:${RESET_FORMAT}"
  echo "A: Task 1 - Create Pub/Sub Schema"
  echo "B: Task 2 - Create Pub/Sub Topic"
  echo "C: Task 3 - Create Trigger Cloud Function"
  echo ""

  read -p "Enter your choice (A/B/C): " user_choice

  case "$user_choice" in
    A|a)
        echo ""
        # 🌍 Fetching Region
        echo "${BRIGHT_GREEN}${BOLD}🔄 Fetching Region...${RESET_FORMAT}"
        export LOCATION=$(gcloud compute project-info describe \
        --format="value(commonInstanceMetadata.items[google-compute-default-region])")
        
        echo "${CYAN_TEXT}${BOLD_TEXT}Creating a Pub/Sub schema using Avro format...${RESET_FORMAT}"
        echo
        gcloud pubsub schemas create city-temp-schema \
                --type=avro \
                --definition='{                                             
                    "type" : "record",                               
                    "name" : "Avro",                                 
                    "fields" : [                                     
                    {                                                
                        "name" : "city",                             
                        "type" : "string"                            
                    },                                               
                    {                                                
                        "name" : "temperature",                      
                        "type" : "double"                            
                    },                                               
                    {                                                
                        "name" : "pressure",                         
                        "type" : "int"                               
                    },                                               
                    {                                                
                        "name" : "time_position",                    
                        "type" : "string"                            
                    }                                                
                ]                                                    
            }'
        
        echo
        echo "${GREEN_TEXT}${BOLD_TEXT}Step 2:${RESET_FORMAT} ${GREEN_TEXT}Creating a Pub/Sub topic with JSON message encoding.${RESET_FORMAT}"
        echo
        gcloud pubsub topics create temp-topic \
                --message-encoding=JSON \
                --schema=temperature-schema
        
        echo
        echo "${MAGENTA_TEXT}${BOLD_TEXT}Step 3:${RESET_FORMAT} ${MAGENTA_TEXT}Enabling required Google Cloud services.${RESET_FORMAT}"
        echo
        gcloud services enable eventarc.googleapis.com
        gcloud services enable run.googleapis.com
        
        echo
        echo "${BLUE_TEXT}${BOLD_TEXT}Step 4:${RESET_FORMAT} ${BLUE_TEXT}Creating Node.js function code that processes Pub/Sub messages.${RESET_FORMAT}"
        echo
        cat > index.js <<'EOF'
        const functions = require('@google-cloud/functions-framework');
        
        // Register a CloudEvent callback with the Functions Framework that will
        // be executed when the Pub/Sub trigger topic receives a message.
        functions.cloudEvent('helloPubSub', cloudEvent => {
          // The Pub/Sub message is passed as the CloudEvent's data payload.
          const base64name = cloudEvent.data.message.data;
        
          const name = base64name
            ? Buffer.from(base64name, 'base64').toString()
            : 'World';
        
          console.log(`Hello, ${name}!`);
        });
        EOF
        
        echo
        echo "${YELLOW_TEXT}${BOLD_TEXT}Step 5:${RESET_FORMAT} ${YELLOW_TEXT}Creating package.json with required dependencies.${RESET_FORMAT}"
        echo
        cat > package.json <<'EOF'
        {
          "name": "gcf_hello_world",
          "version": "1.0.0",
          "main": "index.js",
          "scripts": {
            "start": "node index.js",
            "test": "echo \"Error: no test specified\" && exit 1"
          },
          "dependencies": {
            "@google-cloud/functions-framework": "^3.0.0"
          }
        }
        EOF
        
        echo
        echo "${RED_TEXT}${BOLD_TEXT}Step 6:${RESET_FORMAT} ${RED_TEXT}Deploying the Cloud Function with Pub/Sub trigger.${RESET_FORMAT}"
        echo
        deploy_function() {
        gcloud functions deploy gcf-pubsub \
          --gen2 \
          --runtime=nodejs22 \
          --region=$LOCATION \
          --source=. \
          --entry-point=helloPubSub \
          --trigger-topic gcf-topic \
          --quiet
          }
        
        deploy_success=false
        
        echo "${CYAN_TEXT}${BOLD_TEXT}Deployment Status:${RESET_FORMAT} ${CYAN_TEXT}Attempting to deploy function...${RESET_FORMAT}"
        echo
        while [ "$deploy_success" = false ]; do
            if deploy_function; then
                echo "${GREEN_TEXT}${BOLD_TEXT}Success:${RESET_FORMAT} ${GREEN_TEXT}Function deployed successfully...${RESET_FORMAT}"
                deploy_success=true
            else
                echo "${YELLOW_TEXT}${BOLD_TEXT}Retrying:${RESET_FORMAT} ${YELLOW_TEXT}Deployment failed, will retry in 20 seconds...${RESET_FORMAT}"
                sleep 20
            fi
        done
        break
        ;;
    B|b)
        echo ""
        # 🌍 Fetching Region
        echo "${BRIGHT_GREEN}${BOLD}🔄 Fetching Region...${RESET_FORMAT}"
        export LOCATION=$(gcloud compute project-info describe \
        --format="value(commonInstanceMetadata.items[google-compute-default-region])")
        
        export MSG_BODY='Hello World!'
        
        echo
        echo "${BLUE_TEXT}${BOLD_TEXT}Creating a Pub/Sub topic to publish messages...${RESET_FORMAT}"
        echo
        gcloud pubsub topics create cloud-pubsub-topic
        
        echo
        echo "${CYAN_TEXT}${BOLD_TEXT}Creating a subscription to receive messages from our topic...${RESET_FORMAT}"
        echo
        gcloud pubsub subscriptions create cloud-pubsub-subscription --topic=cloud-pubsub-topic
        
        echo
        echo "${MAGENTA_TEXT}${BOLD_TEXT}Enabling the Cloud Scheduler service...${RESET_FORMAT}"
        echo
        gcloud services enable cloudscheduler.googleapis.com
        
        echo
        echo "${GREEN_TEXT}${BOLD_TEXT}Creating a scheduler job that publishes messages every minute...${RESET_FORMAT}"
        echo
        gcloud scheduler jobs create pubsub cron-scheduler-job \
          --location=$LOCATION \
          --schedule="* * * * *" \
          --topic=cloud-pubsub-topic \
          --message-body="Hello World!"
        
        echo
        echo "${YELLOW_TEXT}${BOLD_TEXT}Pulling messages from our subscription to verify delivery...${RESET_FORMAT}"
        echo
        gcloud pubsub subscriptions pull cloud-pubsub-subscription --limit 5
        break
        ;;
    C|c)
        echo ""
        echo "${CYAN_TEXT}${BOLD_TEXT}Step 1:${RESET_FORMAT} ${CYAN_TEXT}Creating a subscription to our topic.${RESET_FORMAT}"
        echo
        
        gcloud pubsub subscriptions create pubsub-subscription-message --topic gcloud-pubsub-topic
        
        echo
        echo "${YELLOW_TEXT}${BOLD_TEXT}Step 2:${RESET_FORMAT} ${YELLOW_TEXT}Publishing a simple message to our topic.${RESET_FORMAT}"
        echo "${YELLOW_TEXT}The message '${BOLD_TEXT}Hello World${RESET_FORMAT}${YELLOW_TEXT}' will be sent to all subscriptions.${RESET_FORMAT}"
        echo
        
        gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World"
        
        echo
        echo "${MAGENTA_TEXT}${BOLD_TEXT}Waiting:${RESET_FORMAT} ${MAGENTA_TEXT}Allowing time for message to be processed...${RESET_FORMAT}"
        echo
        
        sleep 10
        
        echo
        echo "${GREEN_TEXT}${BOLD_TEXT}Step 3:${RESET_FORMAT} ${GREEN_TEXT}Pulling messages from our subscription.${RESET_FORMAT}"
        echo "${GREEN_TEXT}This retrieves up to ${BOLD_TEXT}5${RESET_FORMAT}${GREEN_TEXT} messages that were sent to our topic.${RESET_FORMAT}"
        echo
        
        gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5
        
        echo
        echo "${RED_TEXT}${BOLD_TEXT}Step 4:${RESET_FORMAT} ${RED_TEXT}Creating a snapshot of our subscription.${RESET_FORMAT}"
        echo
        
        gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription
        break
        ;;
    *)
        echo ""
        echo "${RED_TEXT}${BOLD_TEXT}⚠️ Oops! Invalid input detected.${RESET_FORMAT}"
        echo "${YELLOW_TEXT}Please choose only A, B, or C to continue.${RESET_FORMAT}"
        echo ""
        ;;
  esac
done

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}               ✅ ALL TASKS COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your progress."
echo "${GREEN_TEXT}${BOLD_TEXT} If it will be not completed, try again for successfully completion of the Assessment."
sleep 10
echo ""

remove_temp_files() {
    echo "${YELLOW}${BOLD}Cleaning up temporary files...${RESET}"
    for file in *; do
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            [[ -f "$file" ]] && rm "$file" && echo "Removed: $file"
        fi
    done
}
remove_temp_files

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}          ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!          ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA Section
echo -e "${YELLOW_TEXT}${BOLD}🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo -e "${RED_TEXT}${BOLD}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD}Follow me on LinkedIn:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.linkedin.com/in/iaadillatif${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD}LinkedIn Page:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.linkedin.com/company/techxninjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
