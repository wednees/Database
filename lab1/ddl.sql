CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    price NUMERIC(10, 2),
    country TEXT,
    stock INT,
    created_at TIMESTAMP
);
