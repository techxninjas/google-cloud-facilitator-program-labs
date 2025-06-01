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
echo "${CYAN_TEXT}${BOLD_TEXT}       Perform Predictive Data Analysis in BigQuery: Challenge Lab      ${RESET_FORMAT}"
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

read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the Events Table Name (Check in the Left Panel of Lab): ${RESET_FORMAT}" EVENT
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the Tags Table Name (Check in the Left Panel of Lab): ${RESET_FORMAT}" TABLE
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter value for Model Name (Check in the Left Panel of Lab): ${RESET_FORMAT}" MODEL
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the value of 1st X-coordinate (Check Task 3 of your Lab): ${RESET_FORMAT}" VALUE_X1
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the value of 1st Y-coordinate (Check Task 3 of your Lab): ${RESET_FORMAT}" VALUE_Y1
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the value of 2nd X-coordinate (Check Task 3 of your Lab): ${RESET_FORMAT}" VALUE_X2
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the value of 2nd Y-coordinate (Check Task 3 of your Lab): ${RESET_FORMAT}" VALUE_Y2
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the 1st Function name (Check Task 4 of your Lab): ${RESET_FORMAT}" FUNC_1
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the 2nd Function name (Check Task 4 of your Lab): ${RESET_FORMAT}" FUNC_2
echo

export EVENT
export TABLE
export VALUE_X1
export VALUE_Y1
export VALUE_X2
export VALUE_Y2
export FUNC_1
export FUNC_2
export MODEL

echo "${BLUE_TEXT}${BOLD_TEXT}---> Loading data into BigQuery tables...${RESET_FORMAT}"
bq load --source_format=NEWLINE_DELIMITED_JSON --autodetect $DEVSHELL_PROJECT_ID:soccer.$EVENT gs://spls/bq-soccer-analytics/events.json
bq load --source_format=CSV --autodetect $DEVSHELL_PROJECT_ID:soccer.$TABLE gs://spls/bq-soccer-analytics/tags2name.csv
bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $DEVSHELL_PROJECT_ID:soccer.competitions gs://spls/bq-soccer-analytics/competitions.json
bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $DEVSHELL_PROJECT_ID:soccer.matches gs://spls/bq-soccer-analytics/matches.json
bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $DEVSHELL_PROJECT_ID:soccer.teams gs://spls/bq-soccer-analytics/teams.json
bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $DEVSHELL_PROJECT_ID:soccer.players gs://spls/bq-soccer-analytics/players.json
bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $DEVSHELL_PROJECT_ID:soccer.events gs://spls/bq-soccer-analytics/events.json

echo "${BLUE_TEXT}${BOLD_TEXT}---> Running the first query to analyze penalty success rates...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
playerId,
(Players.firstName || ' ' || Players.lastName) AS playerName,
COUNT(id) AS numPKAtt,
SUM(IF(101 IN UNNEST(tags.id), 1, 0)) AS numPKGoals,
SAFE_DIVIDE(
SUM(IF(101 IN UNNEST(tags.id), 1, 0)),
COUNT(id)
) AS PKSuccessRate
FROM
\`soccer.$EVENT\` Events
LEFT JOIN
\`soccer.players\` Players ON
Events.playerId = Players.wyId
WHERE
eventName = 'Free Kick' AND
subEventName = 'Penalty'
GROUP BY
playerId, playerName
HAVING
numPkAtt >= 5
ORDER BY
PKSuccessRate DESC, numPKAtt DESC
"

echo "${BLUE_TEXT}${BOLD_TEXT}---> Running the second query to analyze shot distances and goal percentages...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
WITH
Shots AS
(
SELECT
*,
/* 101 is known Tag for 'goals' from goals table */
(101 IN UNNEST(tags.id)) AS isGoal,
/* Translate 0-100 (x,y) coordinate-based distances to absolute positions
using "average" field dimensions of 105x68 before combining in 2D dist calc */
SQRT(
POW(
    (100 - positions[ORDINAL(1)].x) * $VALUE_X1/$VALUE_Y1,
    2) +
POW(
    (60 - positions[ORDINAL(1)].y) * $VALUE_X2/$VALUE_Y2,
    2)
 ) AS shotDistance
FROM
\`soccer.$EVENT\`
WHERE
/* Includes both "open play" & free kick shots (including penalties) */
eventName = 'Shot' OR
(eventName = 'Free Kick' AND subEventName IN ('Free kick shot', 'Penalty'))
)
SELECT
ROUND(shotDistance, 0) AS ShotDistRound0,
COUNT(*) AS numShots,
SUM(IF(isGoal, 1, 0)) AS numGoals,
AVG(IF(isGoal, 1, 0)) AS goalPct
FROM
Shots
WHERE
shotDistance <= 50
GROUP BY
ShotDistRound0
ORDER BY
ShotDistRound0
"

echo "${BLUE_TEXT}${BOLD_TEXT}---> Creating a machine learning model in BigQuery...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
CREATE MODEL \`$MODEL\`
OPTIONS(
model_type = 'LOGISTIC_REG',
input_label_cols = ['isGoal']
) AS
SELECT
Events.subEventName AS shotType,
/* 101 is known Tag for 'goals' from goals table */
(101 IN UNNEST(Events.tags.id)) AS isGoal,
\`$FUNC_1\`(Events.positions[ORDINAL(1)].x,
Events.positions[ORDINAL(1)].y) AS shotDistance,
\`$FUNC_2\`(Events.positions[ORDINAL(1)].x,
Events.positions[ORDINAL(1)].y) AS shotAngle
FROM
\`soccer.$EVENT\` Events
LEFT JOIN
\`soccer.matches\` Matches ON
Events.matchId = Matches.wyId
LEFT JOIN
\`soccer.competitions\` Competitions ON
Matches.competitionId = Competitions.wyId
WHERE
/* Filter out World Cup matches for model fitting purposes */
Competitions.name != 'World Cup' AND
/* Includes both "open play" & free kick shots (including penalties) */
(
eventName = 'Shot' OR
(eventName = 'Free Kick' AND subEventName IN ('Free kick shot', 'Penalty'))
) AND
\`$FUNC_2\`(Events.positions[ORDINAL(1)].x,
Events.positions[ORDINAL(1)].y) IS NOT NULL
;
"

echo "${BLUE_TEXT}${BOLD_TEXT}---> Running predictions using the created model...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
predicted_isGoal_probs[ORDINAL(1)].prob AS predictedGoalProb,
* EXCEPT (predicted_isGoal, predicted_isGoal_probs),
FROM
ML.PREDICT(
MODEL \`$MODEL\`, 
(
 SELECT
     Events.playerId,
     (Players.firstName || ' ' || Players.lastName) AS playerName,
     Teams.name AS teamName,
     CAST(Matches.dateutc AS DATE) AS matchDate,
     Matches.label AS match,
 /* Convert match period and event seconds to minute of match */
     CAST((CASE
         WHEN Events.matchPeriod = '1H' THEN 0
         WHEN Events.matchPeriod = '2H' THEN 45
         WHEN Events.matchPeriod = 'E1' THEN 90
         WHEN Events.matchPeriod = 'E2' THEN 105
         ELSE 120
         END) +
         CEILING(Events.eventSec / 60) AS INT64)
         AS matchMinute,
     Events.subEventName AS shotType,
     /* 101 is known Tag for 'goals' from goals table */
     (101 IN UNNEST(Events.tags.id)) AS isGoal,
 
     \`soccer.$FUNC_1\`(Events.positions[ORDINAL(1)].x,
             Events.positions[ORDINAL(1)].y) AS shotDistance,
     \`soccer.$FUNC_2\`(Events.positions[ORDINAL(1)].x,
             Events.positions[ORDINAL(1)].y) AS shotAngle
 FROM
     \`soccer.$EVENT\` Events
 LEFT JOIN
     \`soccer.matches\` Matches ON
             Events.matchId = Matches.wyId
 LEFT JOIN
     \`soccer.competitions\` Competitions ON
             Matches.competitionId = Competitions.wyId
 LEFT JOIN
     \`soccer.players\` Players ON
             Events.playerId = Players.wyId
 LEFT JOIN
     \`soccer.teams\` Teams ON
             Events.teamId = Teams.wyId
 WHERE
     /* Look only at World Cup matches to apply model */
     Competitions.name = 'World Cup' AND
     /* Includes both "open play" & free kick shots (but not penalties) */
     (
         eventName = 'Shot' OR
         (eventName = 'Free Kick' AND subEventName IN ('Free kick shot'))
     ) AND
     /* Filter only to goals scored */
     (101 IN UNNEST(Events.tags.id))
)
)
ORDER BY
predictedgoalProb
"

echo
echo "${CYAN_TEXT}${BOLD_TEXT}====================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}      NOW SEE THE VIDEO CAREFULLY FOR NEXT TASKS     ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}====================================================${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}===> Open BigQuery Console: ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT} https://console.cloud.google.com/bigquery ${RESET_FORMAT}" 

for i in {1..60}; do
    echo -ne "${CYAN_TEXT}⏳ Waiting for ${i}/60 seconds to do this above mentioned task! \r${RESET_FORMAT}"
    sleep 1
done

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
