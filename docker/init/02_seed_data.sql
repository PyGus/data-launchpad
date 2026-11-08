INSERT INTO raw.customers (name, email, created_at) VALUES
('Alice Johnson', 'alice@example.com', '2026-01-10 08:30:00Z'),
('Bob Smith', 'bob@example.com', '2026-01-12 11:15:00Z'),
('Charlie Brown', 'charlie@example.com', '2026-01-15 14:00:00Z');

INSERT INTO raw.orders (customer_id, status, total_amount, order_date) VALUES
(1, 'completed', 150.00, '2026-01-11 09:00:00Z'),
(1, 'completed', 85.50, '2026-01-18 12:45:00Z'),
(2, 'pending', 45.00, '2026-01-19 16:20:00Z'),
(3, 'cancelled', 210.00, '2026-01-20 10:10:00Z');
