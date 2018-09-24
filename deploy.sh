#!/bin/sh

target_env=$1
profile=$2

# Your environments.

if [[ $target_env != "prod" ]] && [[ $target_env != "staging" ]] && [[ $target_env != "testing" ]]; then
  echo "Specify stage. prod/staging/testing."
  exit 1
fi

if [ -z $2 ]; then
  echo "Specity your aws-cli profile."
  exit 1
fi

# Your CF distribution ids.
case "$1" in
  "prod")     dist_id="" ;;
  "staging")  dist_id="" ;;
  "testing")  dist_id="" ;;
esac


# Build for target envs.
echo "BUILD for $target_env"
yarn prebuild
yarn build:$target_env

## Deploy /build to s3. (Your bucket name.)
echo "DEPLOY for $target_env"
aws s3 sync build/ s3://$target_env.bucket-name --profile $profile

## Invalidate cache.
echo "Invalidate CACHE..."
aws cloudfront create-invalidation --distribution-id $dist_id --paths '/*' --profile $profile
