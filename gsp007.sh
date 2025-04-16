#!/bin/bash
clear

# =====================[ Color Setup ]===================== #
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Text colors
BLACK=$(tput setaf 0); RED=$(tput setaf 1); GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3); BLUE=$(tput setaf 4); MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6); WHITE=$(tput setaf 7)

# Background colors
BG_BLACK=$(tput setab 0); BG_RED=$(tput setab 1); BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3); BG_BLUE=$(tput setab 4); BG_MAGENTA=$(tput setab 5)
BG_CYAN=$(tput setab 6); BG_WHITE=$(tput setab 7)

# Text + Background Color Randomizer
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)
RANDOM_TEXT=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

# ====================[ Banner Message ]==================== #
print_banner() {
    echo "${CYAN}${BOLD}🚀===========================================================${RESET}"
    echo "${CYAN}${BOLD}     7th Lab: Set Up Network and Application Load Balancers   ${RESET}"
    echo "${CYAN}${BOLD}        4th Game: Cloud Infrastructure & API Essentials        ${RESET}"
    echo "${CYAN}${BOLD}===========================================================🚀${RESET}"
    echo ""
}
print_banner

# ===================[ Utility Functions ]================== #
checkpoint() {
    echo ""
    echo "${CYAN}${BOLD}🚀===========================================================${RESET}"
    echo "${CYAN}${BOLD}     ✅ Check your progress for $1 ${RESET}"
    echo "${CYAN}${BOLD}===========================================================🚀${RESET}"
    echo ""
    sleep 20
}

remove_temp_files() {
    echo "${YELLOW}${BOLD}Cleaning up temporary files...${RESET}"
    for file in *; do
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            [[ -f "$file" ]] && rm "$file" && echo "Removed: $file"
        fi
    done
}

# ======================[ Task 1: Setup ]===================== #
echo "${CYAN}${BOLD}Task 1: Setting Zone and Region${RESET}"
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
gcloud config set compute/zone "$ZONE"

# ====================[ Task 2: Instances ]=================== #
echo "${MAGENTA}${BOLD}Task 2: Creating Compute Instances${RESET}"

create_instance() {
    NAME=$1
    gcloud compute instances create "$NAME" \
        --zone="$ZONE" \
        --tags=network-lb-tag \
        --machine-type=e2-small \
        --image-family=debian-11 \
        --image-project=debian-cloud \
        --metadata=startup-script="#!/bin/bash
            apt-get update
            apt-get install apache2 -y
            service apache2 restart
            echo '<h3>Web Server: $NAME</h3>' > /var/www/html/index.html"
}

create_instance www1
create_instance www2
create_instance www3

echo "${YELLOW}${BOLD}Creating Firewall Rules${RESET}"
gcloud compute firewall-rules create www-firewall-network-lb \
    --target-tags network-lb-tag \
    --allow tcp:80

gcloud compute instances list
checkpoint "Task 2"

# ============[ Task 3: Network Load Balancer ]============== #
echo "${BLUE}${BOLD}Task 3: Creating Address and Load Balancer${RESET}"

gcloud compute addresses create network-lb-ip-1 --region "$REGION"
gcloud compute http-health-checks create basic-check

gcloud compute target-pools create www-pool \
  --region "$REGION" \
  --http-health-check basic-check

gcloud compute target-pools add-instances www-pool \
  --instances www1,www2,www3

gcloud compute forwarding-rules create www-rule \
  --region "$REGION" \
  --ports 80 \
  --address network-lb-ip-1 \
  --target-pool www-pool

IPADDRESS=$(gcloud compute forwarding-rules describe www-rule --region "$REGION" --format="value(IPAddress)")
checkpoint "Task 3"

# ============[ Task 5: Application Load Balancer ]========== #
echo "${GREEN}${BOLD}Task 5: Creating Application Load Balancer${RESET}"

gcloud compute instance-templates create lb-backend-template \
   --region="$REGION" \
   --network=default \
   --subnet=default \
   --tags=allow-health-check \
   --machine-type=e2-medium \
   --image-family=debian-11 \
   --image-project=debian-cloud \
   --metadata=startup-script="#!/bin/bash
     apt-get update
     apt-get install apache2 -y
     a2ensite default-ssl
     a2enmod ssl
     HOSTNAME=\$(curl -H 'Metadata-Flavor: Google' http://169.254.169.254/computeMetadata/v1/instance/name)
     echo 'Page served from: '\$HOSTNAME > /var/www/html/index.html
     systemctl restart apache2"

gcloud compute instance-groups managed create lb-backend-group \
   --template=lb-backend-template \
   --size=2 \
   --zone="$ZONE"

# =============[ Health Check, URL Map, Forwarding ]============= #
echo "${RED}${BOLD}Configuring Health Checks and URL Maps${RESET}"

gcloud compute firewall-rules create fw-allow-health-check \
  --network=default \
  --action=allow \
  --direction=ingress \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=allow-health-check \
  --rules=tcp:80

gcloud compute addresses create lb-ipv4-1 --ip-version=IPV4 --global

gcloud compute health-checks create http http-basic-check --port 80

gcloud compute backend-services create web-backend-service \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=http-basic-check \
  --global

gcloud compute backend-services add-backend web-backend-service \
  --instance-group=lb-backend-group \
  --instance-group-zone="$ZONE" \
  --global

gcloud compute url-maps create web-map-http \
    --default-service web-backend-service

gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map-http

gcloud compute forwarding-rules create http-content-rule \
   --address=lb-ipv4-1 \
   --global \
   --target-http-proxy=http-lb-proxy \
   --ports=80

checkpoint "Task 5"

# ===================[ Cleanup & Completion ]=================== #
remove_temp_files

echo "${GREEN}${BOLD}🎉===========================================================${RESET}"
echo "${GREEN}${BOLD}       ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!             ${RESET}"
echo "${GREEN}${BOLD}🎉===========================================================${RESET}"
echo ""

# =====================[ Final CTAs ]===================== #
echo "${YELLOW}${BOLD}🔔 Follow for more labs & tutorials:${RESET}"
echo -e "${RED}${BOLD}YouTube:${RESET} ${BLUE}https://www.youtube.com/@TechXNinjas${RESET}"
echo -e "${WHITE}${BOLD}LinkedIn:${RESET} ${BLUE}https://www.linkedin.com/in/iaadillatif${RESET}"
echo -e "${WHITE}${BOLD}TechXNinjas Page:${RESET} ${BLUE}https://www.linkedin.com/company/techxninjas${RESET}"
echo -e "${WHITE}${BOLD}Join WhatsApp Group:${RESET} ${GREEN}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET}"
echo ""
