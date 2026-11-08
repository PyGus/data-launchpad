with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

final as (
    select
        o.order_id,
        o.customer_id,
        c.customer_name,
        o.order_status,
        o.order_date,
        o.total_amount,
        -- Useful dimensional flags
        case when o.order_status = 'completed' then true else false end as is_completed_order
    from orders o
    left join customers c
        on o.customer_id = c.customer_id
)

select * from final
