#!/bin/bash

FNAME="heroku-env-backup"
EXPIRATION="30"
Green='\033[0;32m'
EC='\033[0m' 
FILENAME=`date +%H_%M_%d%m%Y`
sourceApp="$1"

# terminate script on any fails
set -e

printf "${Green}Start env-dump${EC}"

#download heroku cli
# lgin to cli

time printenv  | gzip >  /tmp/"${FNAME}_${FILENAME}".gz

EXPIRATION_DATE=$(date -d "$EXPIRATION days" +"%Y-%m-%dT%H:%M:%SZ")

printf "${Green}Move env-backup to AWS${EC}"
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_BACKUP AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY_BACKUP AWS_DEFAULT_REGION=$AWS_REGION_BACKUP /app/vendor/bin/aws s3 cp /tmp/"${FNAME}_${FILENAME}".gz s3://$AWS_BUCKET_S3_BACKUP/$FNAME/"${FNAME}_${FILENAME}".gz --expires $EXPIRATION_DATE

# cleaning after all
rm -rf /tmp/"${FNAME}_${FILENAME}".gz
