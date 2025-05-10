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
echo "${CYAN_TEXT}${BOLD_TEXT}              Troubleshooting Common SQL Errors with BigQuery          ${RESET_FORMAT}"
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

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing Query 1st: Fetching all 'fullVisitorId' entries...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
fullVisitorId
FROM \`data-to-insights.ecommerce.rev_transactions\`
"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Query 1st Completed.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing Query 2nd: Retrieving 'fullVisitorId' and 'hits_page_pageTitle' (limit 1000)...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT fullVisitorId hits_page_pageTitle
FROM \`data-to-insights.ecommerce.rev_transactions\` LIMIT 1000
"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Query 2nd Completed.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing Query 3rd: Correctly fetching 'fullVisitorId' and 'hits_page_pageTitle' (limit 1000)...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
  fullVisitorId
  , hits_page_pageTitle
FROM \`data-to-insights.ecommerce.rev_transactions\` LIMIT 1000
"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Query 3rd Completed.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing Query 4th: Counting distinct visitors per page title...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
COUNT(DISTINCT fullVisitorId) AS visitor_count
, hits_page_pageTitle
FROM \`data-to-insights.ecommerce.rev_transactions\`
GROUP BY hits_page_pageTitle
"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Query 4th Completed.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing Query 5th: Counting distinct visitors for 'Checkout Confirmation' page...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
COUNT(DISTINCT fullVisitorId) AS visitor_count
, hits_page_pageTitle
FROM \`data-to-insights.ecommerce.rev_transactions\`
WHERE hits_page_pageTitle = 'Checkout Confirmation'
GROUP BY hits_page_pageTitle
"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Query 5th Completed.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing Query 6th: Aggregating transactions and distinct visitors by city...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
geoNetwork_city,
SUM(totals_transactions) AS totals_transactions,
COUNT( DISTINCT fullVisitorId) AS distinct_visitors
FROM
\`data-to-insights.ecommerce.rev_transactions\`
GROUP BY geoNetwork_city
"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Query 6th Completed.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing Query 7th: Same as Query 6, but ordered by distinct visitors (descending)...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
geoNetwork_city,
SUM(totals_transactions) AS totals_transactions,
COUNT( DISTINCT fullVisitorId) AS distinct_visitors
FROM
\`data-to-insights.ecommerce.rev_transactions\`
GROUP BY geoNetwork_city
ORDER BY distinct_visitors DESC
"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Query 7th Completed.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing Query 8th: Calculating average products ordered per visitor by city...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
geoNetwork_city,
SUM(totals_transactions) AS total_products_ordered,
COUNT( DISTINCT fullVisitorId) AS distinct_visitors,
SUM(totals_transactions) / COUNT( DISTINCT fullVisitorId) AS avg_products_ordered
FROM
\`data-to-insights.ecommerce.rev_transactions\`
GROUP BY geoNetwork_city
ORDER BY avg_products_ordered DESC
"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Query 8th Completed.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing Query 9th: Filtering cities where average products ordered > 20...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
geoNetwork_city,
SUM(totals_transactions) AS total_products_ordered,
COUNT( DISTINCT fullVisitorId) AS distinct_visitors,
SUM(totals_transactions) / COUNT( DISTINCT fullVisitorId) AS avg_products_ordered
FROM
\`data-to-insights.ecommerce.rev_transactions\`
GROUP BY geoNetwork_city
HAVING avg_products_ordered > 20
ORDER BY avg_products_ordered DESC
"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Query 9th Completed.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing Query 10th: Listing distinct product names and categories...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT hits_product_v2ProductName, hits_product_v2ProductCategory
FROM \`data-to-insights.ecommerce.rev_transactions\`
GROUP BY 1,2
"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Query 10th Completed.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing Query 11th: Counting non-null products per category...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
COUNT(hits_product_v2ProductName) as number_of_products,
hits_product_v2ProductCategory
FROM \`data-to-insights.ecommerce.rev_transactions\`
WHERE hits_product_v2ProductName IS NOT NULL
GROUP BY hits_product_v2ProductCategory
ORDER BY number_of_products DESC
"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Query 11th Completed.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}---> Executing Query 12th: Counting distinct non-null products per category (Top 5)...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
COUNT(DISTINCT hits_product_v2ProductName) as number_of_products,
hits_product_v2ProductCategory
FROM \`data-to-insights.ecommerce.rev_transactions\`
WHERE hits_product_v2ProductName IS NOT NULL
GROUP BY hits_product_v2ProductCategory
ORDER BY number_of_products DESC
LIMIT 5
"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Query 12th Completed.${RESET_FORMAT}"
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

remove_temp_files() {
    echo "${BLUE_TEXT}${BOLD_TEXT}---> Cleaning up temporary files...${RESET_FORMAT}"
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
echo -e "${BLUE_TEXT}${BOLD_TEXT}---> 🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo ""
echo -e "${WHITE_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@techxninjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
