#!/bin/bash
set -e
SERVICE_URL='http://ironbroker.flatironschool.com'
SERVICE_ENDPOINT='/e/flatiron_xcpretty'
CURR_DIR="$2"
echo ${CURR_DIR}
NETRC=~/.netrc

if [ -f ${NETRC} ]; then
  if grep -q flatiron-push ${NETRC}; then
    GITHUB_USERNAME=`grep -A1 flatiron-push ${NETRC} | grep login | awk '{print $2}'`
    GITHUB_USER_ID=`grep -A2 flatiron-push ${NETRC} | grep password | awk '{print $2}'`
  else
    echo "Please run the iOS setup script before running any tests."
    exit 1
  fi
else
  echo "Please run the iOS setup script before running any tests."
  exit 1
fi

cd "$1"
gunzip -c -S .xcactivitylog `ls -t | grep 'xcactivitylog' | head -n1` | awk '{ gsub("\r", "\n"); print }' > unixfile.txt
TOTAL_COUNT=`tail -n2 unixfile.txt | grep Executed | awk '{print $2}'`
FAILURE_COUNT=`tail -n2 unixfile.txt | grep Executed | awk '{print $5}'`
PASSING_COUNT=`echo "${TOTAL_COUNT} - ${FAILURE_COUNT}" | bc`
cd ${CURR_DIR}



curl -H "Content-Type: application/json" -X POST --data "{ \"username\": \"${GITHUB_USERNAME}\", \"github_user_id\": \"${GITHUB_USER_ID}\", \"repo_name\": \"${CURR_DIR}\", \"build\": { \"test_suite\": [{\"framework\": \"xcpretty\", \"formatted_output\": [], \"duration\": 0.0, \"build_output\": []}]}, \"total_count\": ${TOTAL_COUNT}, \"passing_count\": ${PASSING_COUNT}, \"failure_count\": ${FAILURE_COUNT}}" http://requestb.in/1d61l631