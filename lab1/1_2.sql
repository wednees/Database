CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS order_items (
  order_id INT REFERENCES orders(id),
  product_id INT REFERENCES products(id),
  quantity INT NOT NULL,
  PRIMARY KEY(order_id, product_id)
);

CREATE TABLE IF NOT EXISTS price_changes (
  id SERIAL PRIMARY KEY,
  product_id INT NOT NULL,
  old_price NUMERIC(10,2) NOT NULL,
  new_price NUMERIC(10,2) NOT NULL,
  changed_at TIMESTAMP NOT NULL DEFAULT now()
);

BEGIN;
  INSERT INTO price_changes(product_id, old_price, new_price)
  SELECT id, price, price * 1.05
  FROM products
  WHERE category = 'Red Wine';

  UPDATE products
  SET price = price * 1.05
  WHERE category = 'Red Wine';
COMMIT;

BEGIN;
INSERT INTO orders DEFAULT VALUES RETURNING id;
SELECT id, stock FROM products 
WHERE id IN (10, 20) 
FOR UPDATE;

INSERT INTO order_items (order_id, product_id, quantity)
VALUES 
  (currval('orders_id_seq'), 10, 3),
  (currval('orders_id_seq'), 20, 1);

UPDATE products SET stock = stock - 3 WHERE id = 10;
UPDATE products SET stock = stock - 1 WHERE id = 20;
COMMIT;