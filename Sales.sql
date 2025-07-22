CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address TEXT
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    payment_method VARCHAR(50) NOT NULL
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0)
);



--INSERTING DATA

INSERT INTO products (name, description, price, stock_quantity) VALUES
('Laptop', 'High performance laptop', 999.99, 10),
('Smartphone', 'Latest model smartphone', 699.99, 20),
('Headphones', 'Noise-cancelling headphones', 199.99, 15);

INSERT INTO customers (first_name, last_name, email, phone, address) VALUES
('John', 'Doe', 'john.doe@example.com', '1234567890', '123 Elm St, Springfield'),
('Jane', 'Smith', 'jane.smith@example.com', '0987654321', '456 Oak St, Springfield');

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2023-10-01 10:00:00', 'Shipped'),
(2, '2023-10-02 11:00:00', 'Processing');

INSERT INTO payments (order_id, payment_date, amount, payment_method) VALUES
(1, '2023-10-01 10:05:00', 999.99, 'Credit Card'),
(2, '2023-10-02 11:05:00', 699.99, 'PayPal');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),  -- 1 Laptop
(2, 2, 1);  -- 1 Smartphone



--JOIN QUERY


SELECT 
    o.id AS order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.name AS product_name,
    oi.quantity,
    o.order_date,
    o.status,
    pay.amount,
    pay.payment_method
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.id
JOIN 
    payments pay ON o.id = pay.order_id
JOIN 
    order_items oi ON o.id = oi.order_id
JOIN 
    products p ON oi.product_id = p.id;

--CREATING VIEWS

CREATE VIEW sales_report AS
SELECT 
    o.id AS order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_date,
    o.status,
    SUM(pay.amount) AS total_amount,
    COUNT(oi.id) AS total_items
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.id
JOIN 
    payments pay ON o.id = pay.order_id
JOIN 
    order_items oi ON o.id = oi.order_id
GROUP BY 
    o.id, c.first_name, c.last_name, o.order_date, o.status;