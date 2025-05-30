\timing

EXPLAIN ANALYZE SELECT * FROM products WHERE price BETWEEN 10 AND 20;
EXPLAIN ANALYZE SELECT * FROM products WHERE created_at > '2024-01-01';
EXPLAIN ANALYZE SELECT * FROM products
WHERE to_tsvector('english', description) @@ plainto_tsquery('english', 'dry wine');

CREATE INDEX idx_price_btree ON products(price);
CREATE INDEX idx_created_at_brin ON products USING BRIN (created_at);

ALTER TABLE products ADD COLUMN description_tsv tsvector;
UPDATE products SET description_tsv = to_tsvector('english', description);

CREATE FUNCTION update_description_tsv() RETURNS trigger AS $$
BEGIN
  NEW.description_tsv := to_tsvector('english', NEW.description);
  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_description_tsv
BEFORE INSERT OR UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION update_description_tsv();

CREATE INDEX idx_description_gin ON products USING GIN (description_tsv);

EXPLAIN ANALYZE SELECT * FROM products WHERE price BETWEEN 10 AND 20;
EXPLAIN ANALYZE SELECT * FROM products WHERE created_at > '2024-01-01';
EXPLAIN ANALYZE SELECT * FROM products
WHERE description_tsv @@ plainto_tsquery('english', 'dry wine');
