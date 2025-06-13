/***
 Deploying Pipelines with Snowflake and dbt Labs
 
 Welcome to the beginning of the Quickstart! 
 Please refer to [the official Deploying Pipelines with Snowflake and dbt Labs Quickstart]
 (https://quickstarts.snowflake.com/guide/data_engineering_with_notebooks/) for all the details including set up steps.
***/

-- Step 00 Setup Git repository

show api integrations;

-- Git連携のため、API統合を作成する
-- CREATE OR REPLACE API INTEGRATION GITHUB_TSHOJI_SF_DBT_INT
--   API_PROVIDER = git_https_api
--   API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-tshoji/sf_dbt.git')
--   ALLOWED_AUTHENTICATION_SECRETS = (all)
--   ENABLED = TRUE
--   ;

show git repositories;
show secrets;

-- GITレポジトリの作成
CREATE OR REPLACE GIT REPOSITORY sf_dbt
  ORIGIN = 'https://github.com/sfc-gh-tshoji/sf_dbt.git'
  API_INTEGRATION = GITHUB_TSHOJI_SF_DBT_INT
  -- GIT_CREDENTIALS = sfc_gh_tshoji_pat
  COMMENT = 'dbtデモ用Github'
;


-- Step 01 Setup dev environment

USE ROLE ACCOUNTADMIN;
USE DATABASE tshoji_db;
USE SCHEMA tshoji_schema;

ALTER GIT REPOSITORY SF_DBT FETCH;

ls @TSHOJI_DB.TSHOJI_SCHEMA.SF_DBT/branches/main;
EXECUTE IMMEDIATE FROM
    @TSHOJI_DB.TSHOJI_SCHEMA.SF_DBT/branches/main/scripts/deploy_environment.sql
    USING (env => 'DEV')
;

-- Step 02 Setup prod environment
USE ROLE ACCOUNTADMIN;
USE DATABASE tshoji_db;
USE SCHEMA tshoji_schema;

ALTER GIT REPOSITORY SF_DBT FETCH;
EXECUTE IMMEDIATE FROM
    @TSHOJI_DB.TSHOJI_SCHEMA.SF_DBT/branches/main/scripts/deploy_environment.sql
    USING (env => 'PROD')
;


-- Step 03 Create TASK
create or replace DBT PROJECT tshoji_db.tshoji_schema.dbt_quickstart 
from snow://workspace/USER$.PUBLIC."sf_dbt"/versions/live/dbt_project/;

desc DBT PROJECT tshoji_db.tshoji_schema.dbt_quickstart;

EXECUTE DBT PROJECT tshoji_db.tshoji_schema.dbt_quickstart
  args='seed --target prod';

EXECUTE DBT PROJECT tshoji_db.tshoji_schema.dbt_quickstart
  args='compile --target prod';

EXECUTE DBT PROJECT tshoji_db.tshoji_schema.dbt_quickstart
  args='run --target prod';
  
CREATE OR ALTER TASK tshoji_db.tshoji_schema.run_dbt_prod
  WAREHOUSE = tshoji_wh
  SCHEDULE = '1 hour'
AS
EXECUTE DBT PROJECT tshoji_db.tshoji_schema.dbt_quickstart
  args='run --target prod';

execute task tshoji_db.tshoji_schema.run_dbt_prod;

-- Step 10 Teardown
USE ROLE ACCOUNTADMIN;
DROP DATABASE dbt_hol_2025_dev;
DROP DATABASE dbt_hol_2025_prod;