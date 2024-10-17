# The script is no longer in use as the data was matched using OpenAI's got-4o-mini-2024-07-18 model.
# The script is kept for reference purposes only.
# Description: This script matches ingredients from recipes with products from Woolworths, Coles, and ALDI to estimate the cost of each recipe. The script uses fuzzy string matching to find the closest matching product for each ingredient and calculates the total cost of the recipe based on the cheapest available products. The script also includes measurement checking to ensure that the quantity of the product meets the recipe requirements. The output is a JSON file containing the recipes with ingredient matches and estimated costs. The script can be run by executing the following command in the terminal: 
# Note: The script requires the following libraries to be installed: pandas, fuzzywuzzy, and python-Levenshtein.
# You can install these libraries using pip by running the following commands:
# pip install pandas
# pip install fuzzywuzzy
# pip install python-Levenshtein

import pandas as pd
import re
import json
from fuzzywuzzy import fuzz

# Load datasets for Woolworths, Coles, ALDI, and recipes
woolworths_data = pd.read_csv('assets/recipes/products/supermarket/old_csv/Woolworths.csv')
coles_data = pd.read_csv('assets/recipes/products/supermarket/old_csv/Coles.csv')
aldi_data = pd.read_csv('assets/recipes/products/supermarket/old_csv/Aldi.csv')
recipes_data = pd.read_json('assets/recipes/D3801 Recipes - Recipes.json')

# Normalize price data by converting price columns to strings
woolworths_data['WOW Price'] = woolworths_data['WOW Price'].astype(str)
coles_data['COL Price'] = coles_data['COL Price'].astype(str)
aldi_data['Price'] = aldi_data['Price'].astype(str)

# Set this variable to True to enable measurement checking, or False to disable it
measurement_checking_enabled = True  # Toggle measurement checking as needed

def extract_ingredient_details(text):
    """
    Extract quantity, unit, and ingredient name from a text string.

    Args:
        text (str): The ingredient text (e.g., "2 cups flour").

    Returns:
        list of tuples: Each tuple contains (quantity, unit, ingredient_name).
    """
    pattern = r'(?P<quantity>\d+\.?\d*)?\s*' \
              r'(?P<unit>ml|g|kg|oz|lb|cup|tbsp|tsp|tablespoon|teaspoon|l)?\s*' \
              r'(?P<name>.+)'
    matches = re.finditer(pattern, text, re.IGNORECASE)
    details = []
    for match in matches:
        # Default to '1' if quantity is missing
        quantity = match.group('quantity') if match.group('quantity') else '1'
        # Default to 'unit' if unit is missing
        unit = match.group('unit') if match.group('unit') else 'unit'
        ingredient_name = match.group('name').strip()
        details.append((quantity, unit, ingredient_name))
    return details

# Apply the ingredient extraction function to the recipes data
recipes_data['ingredient_details'] = recipes_data['ingredients_quantity'].apply(extract_ingredient_details)

def convert_to_standard(quantity, unit):
    """
    Convert a quantity and unit to a standard unit (grams or milliliters).

    Args:
        quantity (str): The numerical quantity.
        unit (str): The unit of measurement.

    Returns:
        float: The quantity converted to a standard unit.

    Raises:
        KeyError: If the unit is not recognized.
    """
    unit_conversions = {
        'cup': 240,       # Cups to milliliters
        'tbsp': 15,       # Tablespoons to milliliters
        'tsp': 5,         # Teaspoons to milliliters
        'tablespoon': 15, # Tablespoons to milliliters
        'teaspoon': 5,    # Teaspoons to milliliters
        'kg': 1000,       # Kilograms to grams
        'g': 1,           # Grams
        'ml': 1,          # Milliliters
        'l': 1000,        # Liters to milliliters
        'oz': 28.35,      # Ounces to grams
        'lb': 453.59,     # Pounds to grams
        'unit': 1         # Default unit (no conversion)
    }
    # Convert quantity to float and apply unit conversion
    return float(quantity) * unit_conversions[unit.lower()]

def extract_measurement(text):
    """
    Extract measurement (quantity and unit) from the end of a text string.

    Args:
        text (str): The text to extract measurement from.

    Returns:
        tuple or None: (quantity, unit) if found, else None.
    """
    pattern = r'(?P<quantity>\d+\.?\d*)\s*' \
              r'(?P<unit>ml|g|kg|l|L)\s*$'
    match = re.search(pattern, text.strip(), re.IGNORECASE)
    if match:
        quantity = match.group('quantity')
        unit = match.group('unit').lower()
        return float(quantity), unit
    else:
        return None

# Extract measurements for Woolworths products from the 'WOW Size' column
woolworths_data['measurement'] = woolworths_data['WOW Size'].apply(
    lambda x: extract_measurement(str(x)) if pd.notnull(x) else None
)

# Extract measurements for Coles products from the 'Brand_Product_Size' column
coles_data['measurement'] = coles_data['Brand_Product_Size'].apply(
    lambda x: extract_measurement(str(x)) if pd.notnull(x) else None
)

# Extract measurements for ALDI products from the 'Product Name' column
aldi_data['measurement'] = aldi_data['Product Name'].apply(
    lambda x: extract_measurement(str(x)) if pd.notnull(x) else None
)

# Prepare product details by creating a 'store_product' column in each dataset
woolworths_data['store_product'] = woolworths_data.apply(lambda x: {
    'name': x['Product Name'],
    'price': x['WOW Price'],
    'store': 'Woolworths',
    'measurement': x['measurement']
}, axis=1)

coles_data['store_product'] = coles_data.apply(lambda x: {
    'name': x['Product Name'],
    'price': x['COL Price'],
    'store': 'Coles',
    'measurement': x['measurement']
}, axis=1)

aldi_data['store_product'] = aldi_data.apply(lambda x: {
    'name': x['Product Name'],
    'price': x['Price'],
    'store': 'ALDI',
    'measurement': x['measurement']
}, axis=1)

def find_cheapest_matches(woolworths_products, coles_products, aldi_products, recipe_ingredients):
    """
    Find the cheapest matching products for each ingredient from each store.

    Args:
        woolworths_products (list): List of Woolworths product dictionaries.
        coles_products (list): List of Coles product dictionaries.
        aldi_products (list): List of ALDI product dictionaries.
        recipe_ingredients (list): List of ingredient tuples (quantity, unit, name).

    Returns:
        list: A list of dictionaries containing match details for each ingredient.
    """
    ingredient_match_details = []
    for ingredient_details in recipe_ingredients:
        quantity, unit, ingredient_name = ingredient_details
        # Attempt to convert ingredient measurement to standard units
        try:
            ingredient_quantity_standard = convert_to_standard(quantity, unit)
            ingredient_measurement_available = True
        except (KeyError, ValueError):
            ingredient_measurement_available = False

        # Initialize a dictionary to hold products per store
        products_per_store = {'Woolworths': [], 'Coles': [], 'ALDI': []}

        # Collect products from each store with a similarity score >= 50%
        for store_products in [woolworths_products, coles_products, aldi_products]:
            for product in store_products:
                # Calculate the similarity between ingredient and product names
                similarity = fuzz.partial_ratio(ingredient_name.lower(), product['name'].lower())
                if similarity >= 50:
                    product_entry = product.copy()
                    product_entry['similarity'] = similarity
                    try:
                        # Convert price to float
                        product_entry['price'] = float(product_entry['price'])
                    except ValueError:
                        continue  # Skip if price conversion fails
                    store = product['store']
                    products_per_store[store].append(product_entry)

        # For each store, sort products by similarity and select top 5
        top_matches_per_store = {}
        for store, products in products_per_store.items():
            products.sort(key=lambda x: x['similarity'], reverse=True)
            top_matches_per_store[store] = products[:5]

        # Apply measurement checks and select the cheapest product per store
        cheapest_per_store = {'Woolworths': None, 'Coles': None, 'ALDI': None}
        store_match_counts = {'Woolworths': 0, 'Coles': 0, 'ALDI': 0}
        for store, products in top_matches_per_store.items():
            for product in products:
                # Measurement checking
                if measurement_checking_enabled and ingredient_measurement_available and product.get('measurement'):
                    try:
                        # Convert product measurement to standard units
                        product_quantity, product_unit = product['measurement']
                        product_quantity_standard = convert_to_standard(product_quantity, product_unit)
                        # Check if product quantity meets recipe requirement
                        if product_quantity_standard >= ingredient_quantity_standard:
                            store_match_counts[store] += 1
                            # Update if this product is cheaper
                            if (cheapest_per_store[store] is None or
                                    product['price'] < cheapest_per_store[store]['price']):
                                cheapest_per_store[store] = product
                        else:
                            continue  # Exclude if quantity is insufficient
                    except (KeyError, ValueError):
                        # Include product if measurement conversion fails
                        store_match_counts[store] += 1
                        if (cheapest_per_store[store] is None or
                                product['price'] < cheapest_per_store[store]['price']):
                            cheapest_per_store[store] = product
                else:
                    # Include product if measurement checking is disabled or measurements are unavailable
                    store_match_counts[store] += 1
                    if (cheapest_per_store[store] is None or
                            product['price'] < cheapest_per_store[store]['price']):
                        cheapest_per_store[store] = product

        # Print the number of matches from each store
        print(f"{ingredient_name}: Woolworths - {store_match_counts['Woolworths']}, "
              f"Coles - {store_match_counts['Coles']}, Aldi - {store_match_counts['ALDI']}")

        # Construct a string showing the cheapest product from each store
        output_str = f"{ingredient_name}: "
        for store in ['Woolworths', 'Coles', 'ALDI']:
            if cheapest_per_store[store]:
                product_name = cheapest_per_store[store]['name']
            else:
                product_name = 'NONE'
            output_str += f"{store} - {product_name}, "
        output_str = output_str.rstrip(', ')
        print(output_str)

        # Build matches for the ingredient
        matches = []
        for store in ['Woolworths', 'Coles', 'ALDI']:
            if cheapest_per_store[store]:
                prod = cheapest_per_store[store]
                matches.append({
                    'store': store,
                    'product_name': prod['name'],
                    'price': round(prod['price'], 2)
                })
            else:
                matches.append({
                    'store': store,
                    'product_name': 'NONE',
                    'price': None
                })

        ingredient_match_details.append({
            'ingredient': ingredient_name,
            'matches': matches
        })

    return ingredient_match_details

new_recipes = []
# Process each recipe individually
for index, row in recipes_data.iterrows():
    # Find the cheapest matches for the recipe's ingredients
    ingredient_matches = find_cheapest_matches(
        woolworths_data['store_product'].tolist(),
        coles_data['store_product'].tolist(),
        aldi_data['store_product'].tolist(),
        row['ingredient_details']
    )

    # Calculate the total cheapest price for the recipe
    total_cheapest_price = 0
    for ingredient in ingredient_matches:
        # Determine the cheapest price among the stores for each ingredient
        cheapest_price = None
        for match in ingredient['matches']:
            if match['price'] is not None:
                if cheapest_price is None or match['price'] < cheapest_price:
                    cheapest_price = match['price']
        if cheapest_price is not None:
            total_cheapest_price += cheapest_price
    total_cheapest_price = round(total_cheapest_price, 2)

    # Construct the new recipe dictionary with all required fields
    new_recipe = {
        "recipe_id": row["recipe_id"],
        "recipe_name": row["recipe_name"],
        "ingredients": row['ingredients_quantity'],
        "ingredient_matches": ingredient_matches,
        "total_cheapest_price": total_cheapest_price,
        "cooking_directions": row["cooking_directions"],
        "prep_time_min": row["prep_time_min"],
        "cook_time_min": row["cook_time_min"],
        "total_time_min": row["total_time_min"],
        "difficulty": row["difficulty"],
        "rating": row["rating"],
        "protein_g": row["protein_g"],
        "energy_kcal": row["energy_kcal"],
        "fat_g": row["fat_g"],
        "saturated_fat_g": row["saturated_fat_g"],
        "carbs_g": row["carbs_g"],
        "sugar_g": row["sugar_g"],
        "sodium_mg": row["sodium_mg"],
        "classification": row["classification"],
        "allergens": row["allergens"],
        "image_link": row["image_link"],
        "image": row["image"]
    }
    new_recipes.append(new_recipe)

# Save the new recipes with ingredient matches to a JSON file
with open('Path/Recipes with ingredient matches.json', 'w') as f:
    json.dump(new_recipes, f, indent=4)

print("Recipes with ingredient matches JSON file created successfully with cost estimates based on cheapest ingredients.")

