#!/bin/sh
set -eu
cd "$(dirname "$0")"

# set dyanmic seedbox IP
# https://www.myanonamouse.net/api/endpoint.php/3/json/dynamicSeedbox.php
# create session, tell it to allow session to set dynamic seedbox IP
# https://www.myanonamouse.net/preferences/index.php?view=security



# this should be all that's necessary, but it fails someimtes so hardcode the id
#response=$(curl -c ./mam.cookies -b ./mam.cookies https://t.myanonamouse.net/json/dynamicSeedbox.php)
mam_id=$(cat mam_id)
response=$(curl --silent -c ./mam.cookies -b "mam_id=$mam_id" https://t.myanonamouse.net/json/dynamicSeedbox.php)
echo "got $response"
# {"Success":true,"msg":"Completed"}
# {"Success":false,"msg":"Last change too recent"}
# {"Success":true,"msg":"No change"}

echo "$response" | grep -q '"Success":true'
