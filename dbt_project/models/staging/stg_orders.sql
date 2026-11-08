with source as (
    select * from {{ source('pg_raw', 'orders') }}
),

renamed as (
    select
        id as order_id,
        customer_id,
        status as order_status,
        total_amount,
        order_date
    from source
)

select * from renamed
