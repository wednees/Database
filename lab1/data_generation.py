from faker import Faker
import csv
import random

fake = Faker()
categories = ['Red Wine', 'White Wine', 'Rosé', 'Sparkling', 'Dessert']
countries = ['France', 'Italy', 'Spain', 'USA', 'Australia', 'Argentina', 'Chile']

with open('products.csv', 'w', newline='', encoding='utf-8') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['name', 'description', 'category', 'price', 'country', 'stock', 'created_at'])

    for _ in range(5_000_000):
        writer.writerow([
            fake.company(),
            fake.text(max_nb_chars=100),
            random.choice(categories),
            round(random.uniform(5, 500), 2),
            random.choice(countries),
            random.randint(0, 10000),
            fake.date_time_this_decade()
        ])
