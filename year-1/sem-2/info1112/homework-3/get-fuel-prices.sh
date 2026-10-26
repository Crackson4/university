#!/bin/bash

IMAGE_NAME='nginx:1.23'

# Error handling for arguments

if [ ! "$#" -eq 1 ]; then
	echo "Error: invalid number of arguments"
	exit 1
fi

if [[ ! "$1" =~ ^[0-9]+$ ]]; then
	echo "Error: argument 1 must be an integer"
	exit 1
fi

# Ensure that nginx image is downloaded

docker image inspect $IMAGE_NAME > /dev/null || docker pull $IMAGE_NAME

# Ensure that container is running

is_running=$(docker container inspect -f '{{.State.Running}}' hw3 2>/dev/null)
image=$(docker container inspect -f '{{.Config.Image}}' hw3 2>/dev/null)

if [ ! "$is_running" = "true" ] || [ ! "$image" = $IMAGE_NAME ]; then
	if [ "$is_running" = "false" ]; then
		docker rm --force hw3
	fi

	docker run -d --name hw3 -p 80:80 -v $(pwd):/usr/share/nginx/html $IMAGE_NAME 
fi

# Get access token from API

token=$(curl --request GET \
	--url 'https://api.onegov.nsw.gov.au/oauth/client_credential/accesstoken?grant_type=client_credentials' \
	--header 'authorization: Basic aER1QWl4TXVzbm41QVBOTlE4ektBdFJSTGJITkJHN2o6S1dRd29JQThRY3N2M0xteA==' \
	--header 'content-type: application/json' \
	| awk -F ' : ' '{ if (/access_token/) {match($2, /[a-zA-Z0-9]+/, m); print m[0]} }')

echo $token

# Get fuel prices

curl --request POST \
	--url 'https://api.onegov.nsw.gov.au/FuelPriceCheck/v1/fuel/prices/location' \
	--header 'apikey: hDuAixMusnn5APNNQ8zKAtRRLbHNBG7j' \
	--header "authorization: Bearer $token" \
	--header 'content-type: application/json' \
	--header "requesttimestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
	--header "transactionid: $(uuidgen)" \
	--data "{\"fueltype\":\"E10\",\"namedlocation\":$1,\"sortby\":\"Price\"}" > fuel.json

# Access nginx server

ipAddr=$(hostname -i)

curl http://$ipAddr/fuel.json


