#!/bin/bash

DBNAME=""
EXPIRATION="30"
Green='\033[0;32m'
EC='\033[0m' 
FILENAME=`date +%H_%M_%d%m%Y`

# terminate script on any fails
set -e

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -exp|--expiration)
    EXPIRATION="$2"
    shift
    ;;
    -db|--dbname)
    DBNAME="$2"
    shift
    ;;
esac
shift
done

if [[ -z "$DBNAME" ]]; then
  echo "Missing DBNAME variable"
  exit 1
fi
if [[ -z "$AWS_ACCESS_KEY_BACKUP" ]]; then
  echo "Missing AWS_ACCESS_KEY_BACKUP variable"
  exit 1
fi
if [[ -z "$AWS_SECRET_KEY_BACKUP" ]]; then
  echo "Missing AWS_SECRET_KEY_BACKUP variable"
  exit 1
fi
if [[ -z "$AWS_REGION_BACKUP" ]]; then
  echo "Missing AWS_REGION_BACKUP variable"
  exit 1
fi
if [[ -z "$AWS_BUCKET_S3_BACKUP" ]]; then
  echo "Missing AWS_BUCKET_S3_BACKUP variable"
  exit 1
fi
if [[ -z "$DATABASE_URL" ]]; then
  echo "Missing DATABASE_URL variable"
  exit 1
fi

printf "${Green}Start dump${EC}"

time pg_dump -b -F c --dbname=$DATABASE_URL | gzip >  /tmp/"${DBNAME}_${FILENAME}".gz

EXPIRATION_DATE=$(date -d "$EXPIRATION days" +"%Y-%m-%dT%H:%M:%SZ")

printf "${Green}Move dump to AWS${EC}"
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_BACKUP AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY_BACKUP AWS_DEFAULT_REGION=$AWS_REGION_BACKUP /app/vendor/bin/aws s3 cp /tmp/"${DBNAME}_${FILENAME}".gz s3://$AWS_BUCKET_S3_BACKUP/$DBNAME/"${DBNAME}_${FILENAME}".gz --expires $EXPIRATION_DATE
# cleaning after all
rm -rf /tmp/"${DBNAME}_${FILENAME}".gz
