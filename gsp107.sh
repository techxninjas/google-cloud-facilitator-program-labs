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
echo "${CYAN_TEXT}${BOLD_TEXT}🚀===========================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}     11th Lab: Cloud Data Loss Prevention API: Qwik Start     ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}        Level 2: Cloud Infrastructure & API Essentials         ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}===========================================================🚀${RESET_FORMAT}"
echo ""

# 🚀 Task Execution Init
echo -e "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET}"
echo -e "${CYAN_TEXT}${BOLD_TEXT}         🚀 INITIATING THE TASK EXECUTION...          ${RESET}"
echo -e "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET}"
echo ""

export PROJECT_ID=$DEVSHELL_PROJECT_ID

cat > inspect-request.json <<EOF_END
{
  "item":{
    "value":"My phone number is (206) 555-0123."
  },
  "inspectConfig":{
    "infoTypes":[
      {
        "name":"PHONE_NUMBER"
      },
      {
        "name":"US_TOLLFREE_PHONE_NUMBER"
      }
    ],
    "minLikelihood":"POSSIBLE",
    "limits":{
      "maxFindingsPerItem":0
    },
    "includeQuote":true
  }
}
EOF_END

gcloud auth print-access-token

curl -s \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:inspect \
  -d @inspect-request.json -o inspect-output.txt

cat inspect-output.txt

gsutil cp inspect-output.txt gs://$DEVSHELL_PROJECT_ID-bucket

cat > new-inspect-file.json <<EOF_END
{
  "item": {
     "value":"My email is test@gmail.com",
   },
   "deidentifyConfig": {
     "infoTypeTransformations":{
          "transformations": [
            {
              "primitiveTransformation": {
                "replaceWithInfoTypeConfig": {}
              }
            }
          ]
        }
    },
    "inspectConfig": {
      "infoTypes": {
        "name": "EMAIL_ADDRESS"
      }
    }
}
EOF_END

curl -s \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:deidentify \
  -d @new-inspect-file.json -o redact-output.txt

cat redact-output.txt

gsutil cp redact-output.txt gs://$DEVSHELL_PROJECT_ID-bucket

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}               ✅ ALL TASKS COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your progress."
echo "${GREEN_TEXT}${BOLD_TEXT} If it will be not completed, try again for successfully completion of the Assessment."
sleep 10
echo ""

remove_temp_files() {
    echo "${YELLOW_TEXT}${BOLD_TEXT}Cleaning up temporary files...${RESET}"
    for file in *; do
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            [[ -f "$file" ]] && rm "$file" && echo "Removed: $file"
        fi
    done
}
remove_temp_files

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}          ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!          ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA Section
echo -e "${YELLOW_TEXT}${BOLD_TEXT}🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo -e "${RED_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@TechXNinjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Follow me on LinkedIn:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE_TEXT}https://www.linkedin.com/in/iaadillatif${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}LinkedIn Page:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE_TEXT}https://www.linkedin.com/company/techxninjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE_TEXT}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
