CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pg_bigm;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE INDEX IF NOT EXISTS products_name_trgm_idx ON products USING gin (name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS products_name_bigm_idx ON products USING gin (name gin_bigm_ops);

INSERT INTO products (name, description, category, price, country, stock, created_at)
VALUES 
    ('Chardonnay California Reserve', 'Smooth oak-aged white wine', 'White', 24.99, 'USA', 120, NOW()),
    ('Pinot Noir Russian River Valley', 'Elegant red with cherry notes', 'Red', 32.50, 'USA', 85, NOW()),
    ('Chardonay Sonoma Coast', 'Crisp mineral-driven white', 'White', 28.75, 'USA', 65, NOW()),
    ('Cabernet Sauvignon Napa Valley', 'Bold tannic red wine', 'Red', 45.00, 'USA', 200, NOW()),
    ('Sauvignon Blanc Marlborough', 'Zesty New Zealand white', 'White', 19.99, 'New Zealand', 150, NOW())
ON CONFLICT DO NOTHING;

ALTER TABLE products ADD COLUMN IF NOT EXISTS supplier_key BYTEA;

DO $$
DECLARE
    encryption_key TEXT := 'winestore_secret_key';
BEGIN
    UPDATE products 
    SET supplier_key = pgp_sym_encrypt('SUPPLIER-' || id::TEXT || '-KEY', encryption_key)
    WHERE supplier_key IS NULL;
END $$;

EXPLAIN ANALYZE 
SELECT id, name, similarity(name, 'Chardoney') AS score
FROM products 
WHERE name % 'Chardoney'  
ORDER BY score DESC
LIMIT 10;

EXPLAIN ANALYZE 
SELECT id, name, name <-> 'Chardoney' AS score
FROM products 
WHERE name %% 'Chardoney' 
ORDER BY score
LIMIT 10;


WITH trgm_results AS (
    SELECT name, 'pg_trgm' AS method
    FROM products 
    WHERE name % 'Chardoney'
    LIMIT 5
),
bigm_results AS (
    SELECT name, 'pg_bigm' AS method
    FROM products 
    WHERE name %% 'Chardoney'
    LIMIT 5
)
SELECT * FROM trgm_results
UNION ALL
SELECT * FROM bigm_results;


DO $$
DECLARE
    encryption_key TEXT := 'winestore_secret_key';
    decrypted_text TEXT;
BEGIN
    RAISE NOTICE 'Шифрованный ключ поставщика: %', 
        (SELECT supplier_key FROM products LIMIT 1);
    
    SELECT pgp_sym_decrypt(supplier_key, encryption_key) 
    INTO decrypted_text
    FROM products 
    LIMIT 1;
    
    RAISE NOTICE 'Дешифрованный ключ: %', decrypted_text;
    
    RAISE NOTICE 'Хеш API-ключа: %', 
        crypt('master_api_key', gen_salt('bf', 8));
END $$;
