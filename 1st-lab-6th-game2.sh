#!/bin/bash
# Define color variables

BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
UNDERLINE=`tput smul`
RESET=`tput sgr0`

BRIGHT_GREEN="${GREEN}"
BRIGHT_YELLOW="${YELLOW}"
BRIGHT_RED="${RED}"
BRIGHT_BLUE="${BLUE}"
BRIGHT_WHITE="${WHITE}"
BRIGHT_PURPLE="${MAGENTA}"
BRIGHT_CYAN="${CYAN}"
RESET_FORMAT="${RESET}"

# 💡 Start-Up Banner 
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}                    6th Game: Lab 1             ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

# 🚀 Task Execution Init
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo -e "${BRIGHT_CYAN}${BOLD}         🚀 INITIATING THE TASK EXECUTION...           ${RESET}"
echo -e "${BRIGHT_PURPLE}${BOLD}-------------------------------------------------------${RESET}"
echo ""

read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the location (Check your Lab and type the Location here): ${RESET_FORMAT}" LOCATION
export LOCATION=$LOCATION
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
export PROJECT_NUMBER=$(gcloud projects list --filter=projectId:$PROJECT_ID \
  --format="value(projectNumber)")
export DATASET_ID=dataset1
export FHIR_STORE_ID=fhirstore1
export TOPIC=fhir-topic
export HL7_STORE_ID=hl7v2store1

gcloud healthcare fhir-stores export bq de_id \
--dataset=$DATASET_ID \
--location=$LOCATION \
--bq-dataset=bq://$PROJECT_ID.de_id \
--schema-type=analytics

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
echo "${BRIGHT_GREEN}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo "${BRIGHT_GREEN}${BOLD}              ✅ YOU'VE ONLY COMPLETED HALF LAB!         ${RESET_FORMAT}"
echo "${BRIGHT_GREEN}${BOLD}   ✅ NOW PLEASE WATCH THIS VIDEO TO COMPLETE THE FULL LAB:   ${RESET_FORMAT}"
echo -e "${BRIGHT_RED}${BOLD}Video:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://youtu.be/r0YaZR51dUs${RESET}"
echo "${BRIGHT_GREEN}${BOLD}🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA
echo -e "${BRIGHT_YELLOW}${BOLD}🔔 Follow for more labs & tutorials:${RESET}"
echo -e "${BRIGHT_RED}${BOLD}YouTube Channel:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.youtube.com/@TechXNinjas${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}Follow me on LinkedIn:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.linkedin.com/in/iaadillatif${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}LinkedIn Page:${RESET} ${BRIGHT_BLUE}${UNDERLINE}https://www.linkedin.com/company/techxninjas${RESET}"
echo -e "${BRIGHT_WHITE}${BOLD}Join WhatsApp Group:${RESET} ${BRIGHT_GREEN}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET}"
echo ""
