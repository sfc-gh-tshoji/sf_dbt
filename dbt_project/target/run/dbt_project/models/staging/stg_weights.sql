
  
    

        create or replace transient table dbt_hol_2025_dev.public_01_staging.stg_weights
         as
        (with source as (
    select *
    from dbt_hol_2025_dev.public.weights_table
),
renamed as (
    select region,
        desk,
        target_allocation
    from source
)
select *
from renamed
        );
      
  