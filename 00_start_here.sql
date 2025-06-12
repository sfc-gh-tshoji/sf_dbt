/***
 Deploying Pipelines with Snowflake and dbt Labs
 
 Welcome to the beginning of the Quickstart! 
 Please refer to [the official Deploying Pipelines with Snowflake and dbt Labs Quickstart]
 (https://quickstarts.snowflake.com/guide/data_engineering_with_notebooks/) for all the details including set up steps.
***/

-- Step 01 Setup dev environment

USE ROLE ACCOUNTADMIN;
USE DATABASE tshoji_db;
USE SCHEMA tshoji_schema;

ALTER GIT REPOSITORY SF_DBT FETCH;
EXECUTE IMMEDIATE FROM
    @TSHOJI_DB.TSHOJI_SCHEMA.SF_DBT/branches/main/sfguide-deploying-pipelines-with-snowflake-and-dbt-labs-main/scripts/deploy_environment.sql
    USING (env => 'DEV')
;

-- Step 02 Setup prod environment
USE ROLE ACCOUNTADMIN;
USE DATABASE tshoji_db;
USE SCHEMA tshoji_schema;

ALTER GIT REPOSITORY SF_DBT FETCH;
EXECUTE IMMEDIATE FROM
    @TSHOJI_DB.TSHOJI_SCHEMA.SF_DBT/branches/main/sfguide-deploying-pipelines-with-snowflake-and-dbt-labs-main/scripts/deploy_environment.sql
    USING (env => 'PROD')
;

-- Step 10 Teardown
USE ROLE ACCOUNTADMIN;
DROP DATABASE dbt_hol_2025_dev;
DROP DATABASE dbt_hol_2025_prod;