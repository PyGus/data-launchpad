with source as (
    select * from {{ source('pg_raw', 'customers') }}
),

renamed as (
    select
        id as customer_id,
        name as customer_name,
        lower(email) as email,
        created_at
    from source
    )

select * from renamed
