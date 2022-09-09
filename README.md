# Postman Bitbucket pipeline example

This project demonstrates using Newman to run Postman collections through the bitbucket CI system in different environments.
<br />
<br />

# How does it work with Bitbucket Pipelines

All happens in the bitbucket.pipelines.yml file. Bitbucket Pipelines is creating an environment, using the Postman/Newman Docker image, and running the collection file in a container.
Data preparation happens in run-tests.sh file.
<br />
<br />

**OAuth2.0 model is used for authorization.**<br />
<sub>But it can be easily replaced.
<br />

To setup OAuth2.0

use pre-script from tests/oauth2.0-prescript.js in the collection folder, set OAuth_Token as the authorization method, and inherit it in requests<br />
$CLIENT_ID and $CLIENT_SECRET need to be added to [Bitbucket variables](https://support.atlassian.com/bitbucket-cloud/docs/variables-and-secrets/).
<br />

**For environment setting up is used Bash script and custom steps in pipeline**

```bash
if [ "$TEST_ENV" = "STAGING" ]; then
    CLIENT_ID="$STAGING_CLIENT_ID"
    CLIENT_SECRET="$STAGING_CLIENT_SECRET"
    ENV_FILE="Staging.environment.json"
    TEST_COLLECTION="./tests/Staging tests collections.postman_collection.json"
fi
```

**For reporting to Slack is used [newman-reporter-slackmsg](https://github.com/jackcoded/newman-reporter-slackmsg)**
<br />

$SLACK_WEB_HOOK needs to be added to [Bitbucket variables](https://support.atlassian.com/bitbucket-cloud/docs/variables-and-secrets/).

## How to run tests locally:

**Step 1:** run in terminal to give file permissions to be executed

```bash
chmod +x run-tests.sh
```

**Step 2:** run in terminal to set variables

```bash
export STAGING_CLIENT_ID=id STAGING_CLIENT_SECRET=secret SLACK_WEB_HOOK=123
```

**Step 3:** run in terminal to run tests on Staging:

```bash
TEST_ENV='STAGING' POSTMAN_FOLDER='FOLDER_2' POSTMAN_ITERATION_FILE='tests-data/Staging-test-data.json' ./run-tests.sh
```

to run test on Production:

```bash
TEST_ENV='PRODUCTION' POSTMAN_FOLDER='FOLDER_PROD' POSTMAN_ITERATION_FILE='tests-data/Production-test-data.json' ./run-tests.sh
```

<br />

A sample Bitbucket Pipeline project can be found **[here](https://bitbucket.org/ddainton/postman-ci-pipeline-example/src/master/)**
