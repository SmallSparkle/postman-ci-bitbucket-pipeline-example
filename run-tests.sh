#!/usr/bin/env sh

if test -z "$TEST_ENV" 
then
    echo "\$TEST_ENV is empty"
    exit 1
fi

if [ "$TEST_ENV" = "STAGING" ]; then
    CLIENT_ID="$STAGING_CLIENT_ID"
    CLIENT_SECRET="$STAGING_CLIENT_SECRET"
    ENV_FILE="Staging.environment.json"
    TEST_COLLECTION="./tests/Staging tests collections.postman_collection.json"
fi

if [ "$TEST_ENV" = "PRODUCTION" ]; then
    CLIENT_ID="$PROD_CLIENT_ID"
    CLIENT_SECRET="$PROD_CLIENT_SECRET"
    ENV_FILE="PROD.environment.json"
    TEST_COLLECTION="./tests/PROD tests collections.postman_collection.json"
fi

echo "Running tests on $TEST_ENV"

if test -z "$TEST_COLLECTION" 
then
    echo "\$TEST_COLLECTION is empty"
    exit 1
fi

if test -z "$POSTMAN_FOLDER" 
then
    echo "\$POSTMAN_FOLDER is empty"
    exit 1
fi

if test -z "$CLIENT_ID" 
then
    echo "\$CLIENT_ID is empty"
    exit 1
fi

if test -z "$CLIENT_SECRET" 
then
    echo "\$CLIENT_SECRET is empty"
    exit 1
fi

if test -z "$ENV_FILE" 
then
    echo "\$TR_ENV_FILE is empty"
    exit 1
fi

if test -z "$SLACK_WEB_HOOK" 
then
    echo "\$SLACK_WEB_HOOK is empty"
    exit 1
fi

echo "Run newman tests for $POSTMAN_FOLDER"

newman run "$TEST_COLLECTION"  --folder "$POSTMAN_FOLDER" \
    -e ./environment/$ENV_FILE \
    # client_id and client_secret to setup OAuth2.0
    --env-var "clientId=$CLIENT_ID" \
    --env-var "clientSecret=$CLIENT_SECRET" \
    --suppress-exit-code \
    -r slackmsg,cli,json \
    # reporter to slack 
    --reporter-slackmsg-webhookurl "$SLACK_WEB_HOOK" \
    --reporter-slackmsg-environment "$TEST_ENV" \
    --reporter-slackmsg-collection "$POSTMAN_FOLDER" \
    --reporter-json-export test-outputfile.json \
    # file with test data
    --iteration-data "$POSTMAN_ITERATION_FILE" 

jq '[.run.stats[].failed] | add' test-outputfile.json | grep -w "0"