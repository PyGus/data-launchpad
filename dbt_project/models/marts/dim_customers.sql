with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customer_orders as (
    select
        customer_id,
        count(order_id) as total_orders,
        count(case when order_status = 'completed' then 1 end) as total_completed_orders,
        coalesce(sum(case when order_status = 'completed' then total_amount else 0 end), 0) as lifetime_spend
    from orders
    group by 1
),

final as (
    select
        c.customer_id,
        c.customer_name,
        c.email,
        c.created_at,
        coalesce(co.total_orders, 0) as total_orders,
        coalesce(co.total_completed_orders, 0) as total_completed_orders,
        coalesce(co.lifetime_spend, 0.0) as lifetime_spend
    from customers c
    left join customer_orders co
        on c.customer_id = co.customer_id
)

select * from final
