# importe pandas as pd
# import re
# import json
# from fuzzywuzzy import fuzz
# from fuzzywuzzy import process

# # Load datasets
# woolworths_data = pd.read_csv('/home/snackos12/Desktop/DECO3801 Project/Woolworths.csv')
# coles_data = pd.read_csv('/home/snackos12/Desktop/DECO3801 Project/Coles.csv')
# aldi_data = pd.read_csv('/home/snackos12/Desktop/DECO3801 Project/Aldi.csv')
# recipes_data = pd.read_json('/home/snackos12/Desktop/DECO3801 Project/D3801 Recipes - Recipes.json')

# # Convert price columns to string for consistent data handling
# woolworths_data['WOW Price'] = woolworths_data['WOW Price'].astype(str)
# coles_data['COL Price'] = coles_data['COL Price'].astype(str)
# aldi_data['Price'] = aldi_data['Price'].astype(str)

# def extract_ingredient_details(text):
#     pattern = r'(?P<quantity>\d+)\s*(?P<unit>ml|g|kg|oz|lb|cup|tbsp|tsp|tablespoon|teaspoon|l)\s*(?P<name>.+)'
#     matches = re.finditer(pattern, text, re.IGNORECASE)
#     details = []
#     for match in matches:
#         details.append((match.group('quantity'), match.group('unit'), match.group('name').strip()))
#     return details

# recipes_data['ingredient_details'] = recipes_data['ingredients_quantity'].apply(extract_ingredient_details)

# def convert_to_standard(quantity, unit):
#     unit_conversions = {
#         'cup': 240, 'tbsp': 15, 'tsp': 5, 'kg': 1000, 'g': 1, 'ml': 1, 'l': 1000, 'oz': 28.35, 'lb': 453.59
#     }
#     return float(quantity) * unit_conversions.get(unit, 1)

# def find_cheapest_matches(woolworths_products, coles_products, aldi_products, recipe_ingredients):
#     matches = []
#     total_cost = 0
#     all_matched = True

#     for quantity, unit, ingredient in recipe_ingredients:
#         converted_quantity = convert_to_standard(quantity, unit)

#         # Function to find the cheapest match and return price
#         def get_cheapest_price(products):
#             store_matches = [(p['name'], p['price']) for p in products if fuzz.partial_ratio(ingredient, p['name']) > 70 and isinstance(p['price'], str) and p['price'].replace('.', '', 1).isdigit()]
#             if store_matches:
#                 cheapest = min(store_matches, key=lambda x: float(x[1]))
#                 return float(cheapest[1])  # Return the price as a float
#             return None

#         # Get prices from each store
#         ww_price = get_cheapest_price(woolworths_products)
#         coles_price = get_cheapest_price(coles_products)
#         aldi_price = get_cheapest_price(aldi_products)

#         # Determine the cheapest price among the available stores
#         prices = [price for price in [ww_price, coles_price, aldi_price] if price is not None]
#         if prices:
#             cheapest_price = min(prices)
#             total_cost += cheapest_price
#         else:
#             all_matched = False  # If one ingredient has no matches, mark the total cost as approximate

#         # Format match description
#         match_description = f"{quantity} {unit} {ingredient}: Woolworths - {ww_price if ww_price is not None else 'NONE'}, Coles - {coles_price if coles_price is not None else 'NONE'}, ALDI - {aldi_price if aldi_price is not None else 'NONE'}"
#         matches.append(match_description)

#     # Format total cost
#     cost_str = f"{total_cost:.2f}" if all_matched else f"~{total_cost:.2f}"
#     return matches, cost_str


# # Prepare product details including price and store origin
# woolworths_data['store_product'] = woolworths_data.apply(lambda x: {'name': x['Product Name'], 'price': x['WOW Price'], 'store': 'Woolworths'}, axis=1)
# coles_data['store_product'] = coles_data.apply(lambda x: {'name': x['Product Name'], 'price': x['COL Price'], 'store': 'Coles'}, axis=1)
# aldi_data['store_product'] = aldi_data.apply(lambda x: {'name': x['Product Name'], 'price': x['Price'], 'store': 'ALDI'}, axis=1)


# # Adjust the loop where you compile the recipe dictionary
# new_recipes = []
# for index, row in recipes_data.iterrows():
#     matched_ingredients, total_cost = find_cheapest_matches(
#         woolworths_data['store_product'].tolist(),
#         coles_data['store_product'].tolist(),
#         aldi_data['store_product'].tolist(),
#         row['ingredient_details']
#     )
#     new_recipe = {
#         "recipe_id": row["recipe_id"],
#         "recipe_name": row["recipe_name"],
#         "ingredients_quantity": row["ingredients_quantity"],  # Display original ingredients unedited
#         "ingredient_matches": ', '.join(matched_ingredients),
#         "cost": total_cost,
#         # Include all other recipe fields
#         "cooking_directions": row["cooking_directions"],
#         "prep_time_min": row["prep_time_min"],
#         "cook_time_min": row["cook_time_min"],
#         "total_time_min": row["total_time_min"],
#         "difficulty": row["difficulty"],
#         "rating": row["rating"],
#         "protein_g": row["protein_g"],
#         "energy_kcal": row["energy_kcal"],
#         "fat_g": row["fat_g"],
#         "saturated_fat_g": row["saturated_fat_g"],
#         "carbs_g": row["carbs_g"],
#         "sugar_g": row["sugar_g"],
#         "sodium_mg": row["sodium_mg"],
#         "classification": row["classification"],
#         "allergens": row["allergens"],
#         "image_link": row["image_link"],
#         "image": row["image"]
#     }
#     new_recipes.append(new_recipe)

# # Write to a new JSON file
# with open('/home/snackos12/Desktop/DECO3801 Project/Updated Recipes.json', 'w') as f:
#     json.dump(new_recipes, f, indent=4)

# print("Updated recipe JSON file created successfully with cost estimates based on cheapest ingredients.")


"""This one below works well.  Just has some missing letters"""


# import pandas as pd
# import re
# import json
# from fuzzywuzzy import fuzz
# from fuzzywuzzy import process

# # Load datasets: Import data from CSV and JSON files into pandas DataFrames
# woolworths_data = pd.read_csv('/home/snackos12/Desktop/DECO3801 Project/Woolworths.csv')
# coles_data = pd.read_csv('/home/snackos12/Desktop/DECO3801 Project/Coles.csv')
# aldi_data = pd.read_csv('/home/snackos12/Desktop/DECO3801 Project/Aldi.csv')
# recipes_data = pd.read_json('/home/snackos12/Desktop/DECO3801 Project/D3801 Recipes - Recipes.json')

# # Convert price columns to strings to ensure consistency in handling
# woolworths_data['WOW Price'] = woolworths_data['WOW Price'].astype(str)
# coles_data['COL Price'] = coles_data['COL Price'].astype(str)
# aldi_data['Price'] = aldi_data['Price'].astype(str)

# # Extract detailed ingredient information from a raw ingredient string
# def extract_ingredient_details(text):
#     pattern = r'(?P<quantity>\d+)\s*(?P<unit>ml|g|kg|oz|lb|cup|tbsp|tsp|tablespoon|teaspoon|l)\s*(?P<name>.+)'
#     matches = re.finditer(pattern, text, re.IGNORECASE)
#     details = []
#     for match in matches:
#         details.append((match.group('quantity'), match.group('unit'), match.group('name').strip()))
#     return details

# # Apply the extraction function to each row in the recipes DataFrame
# recipes_data['ingredient_details'] = recipes_data['ingredients_quantity'].apply(extract_ingredient_details)

# # Convert ingredient quantities to a standard unit (e.g., all weights to grams, all volumes to milliliters)
# def convert_to_standard(quantity, unit):
#     unit_conversions = {
#         'cup': 240, 'tbsp': 15, 'tsp': 5, 'kg': 1000, 'g': 1, 'ml': 1, 'l': 1000, 'oz': 28.35, 'lb': 453.59
#     }
#     return float(quantity) * unit_conversions.get(unit, 1)

# # Find the cheapest price for each ingredient across multiple stores
# def find_cheapest_matches(woolworths_products, coles_products, aldi_products, recipe_ingredients):
#     matches = []
#     total_cost = 0
#     all_matched = True

#     for quantity, unit, ingredient in recipe_ingredients:
#         converted_quantity = convert_to_standard(quantity, unit)

#         # Nested function to calculate the lowest price for a given ingredient from a list of product options
#         def get_cheapest_price(products):
#             store_matches = [(p['name'], p['price']) for p in products if fuzz.partial_ratio(ingredient, p['name']) > 70 and isinstance(p['price'], str) and p['price'].replace('.', '', 1).isdigit()]
#             if store_matches:
#                 cheapest = min(store_matches, key=lambda x: float(x[1]))
#                 return float(cheapest[1])
#             return None

#         # Compare prices from each store
#         ww_price = get_cheapest_price(woolworths_products)
#         coles_price = get_cheapest_price(coles_products)
#         aldi_price = get_cheapest_price(aldi_products)

#         # Compile the cheapest prices into a list and calculate the total cost
#         prices = [price for price in [ww_price, coles_price, aldi_price] if price is not None]
#         if prices:
#             cheapest_price = min(prices)
#             total_cost += cheapest_price
#         else:
#             all_matched = False

#         # Store the match information
#         match_description = f"{quantity} {unit} {ingredient}: Woolworths - {ww_price if ww_price is not None else 'NONE'}, Coles - {coles_price if coles_price is not None else 'NONE'}, ALDI - {aldi_price if aldi_price is not None else 'NONE'}"
#         matches.append(match_description)

#     # Return both the match descriptions and the formatted total cost
#     cost_str = f"{total_cost:.2f}" if all_matched else f"~{total_cost:.2f}"
#     return matches, cost_str

# # Prepare product data including name, price, and store for easier access
# woolworths_data['store_product'] = woolworths_data.apply(lambda x: {'name': x['Product Name'], 'price': x['WOW Price'], 'store': 'Woolworths'}, axis=1)
# coles_data['store_product'] = coles_data.apply(lambda x: {'name': x['Product Name'], 'price': x['COL Price'], 'store': 'Coles'}, axis=1)
# aldi_data['store_product'] = aldi_data.apply(lambda x: {'name': x['Product Name'], 'price': x['Price'], 'store': 'ALDI'}, axis=1)

# # Generate a new list of recipes with updated ingredient match and cost information
# new_recipes = []
# for index, row in recipes_data.iterrows():
#     matched_ingredients, total_cost = find_cheapest_matches(
#         woolworths_data['store_product'].tolist(),
#         coles_data['store_product'].tolist(),
#         aldi_data['store_product'].tolist(),
#         row['ingredient_details']
#     )
#     new_recipe = {
#         "recipe_id": row["recipe_id"],
#         "recipe_name": row["recipe_name"],
#         "ingredients_quantity": row["ingredients_quantity"],  # Display original ingredients unedited
#         "ingredient_matches": ', '.join(matched_ingredients),
#         "cost": total_cost,
#         # Include all other recipe fields
#         "cooking_directions": row["cooking_directions"],
#         "prep_time_min": row["prep_time_min"],
#         "cook_time_min": row["cook_time_min"],
#         "total_time_min": row["total_time_min"],
#         "difficulty": row["difficulty"],
#         "rating": row["rating"],
#         "protein_g": row["protein_g"],
#         "energy_kcal": row["energy_kcal"],
#         "fat_g": row["fat_g"],
#         "saturated_fat_g": row["saturated_fat_g"],
#         "carbs_g": row["carbs_g"],
#         "sugar_g": row["sugar_g"],
#         "sodium_mg": row["sodium_mg"],
#         "classification": row["classification"],
#         "allergens": row["allergens"],
#         "image_link": row["image_link"],
#         "image": row["image"]
#     }
#     new_recipes.append(new_recipe)

# # Write to a new JSON file
# with open('/home/snackos12/Desktop/DECO3801 Project/Updated Recipes.json', 'w') as f:
#     json.dump(new_recipes, f, indent=4)

# print("Updated recipe JSON file created successfully with cost estimates based on cheapest ingredients.")



"""Trying to check that there is enough of each ingredient"""
# import pandas as pd
# import re
# import json
# from fuzzywuzzy import fuzz
# from fuzzywuzzy import process

# # Load datasets: Load CSV and JSON files into pandas DataFrames.
# woolworths_data = pd.read_csv('/home/snackos12/Desktop/DECO3801 Project/Woolworths.csv')
# coles_data = pd.read_csv('/home/snackos12/Desktop/DECO3801 Project/Coles.csv')
# aldi_data = pd.read_csv('/home/snackos12/Desktop/DECO3801 Project/Aldi.csv')
# recipes_data = pd.read_json('/home/snackos12/Desktop/DECO3801 Project/D3801 Recipes - Recipes.json')

# # Ensure price data is consistent by converting all prices to strings.
# woolworths_data['WOW Price'] = woolworths_data['WOW Price'].astype(str)
# coles_data['COL Price'] = coles_data['COL Price'].astype(str)
# aldi_data['Price'] = aldi_data['Price'].astype(str)

# # Extract ingredients' details from a raw text string using regular expressions.
# # def extract_ingredient_details(text):
# #     pattern = r'(?P<quantity>\d+)\s*(?P<unit>ml|g|kg|oz|lb|cup|tbsp|tsp|tablespoon|teaspoon|l)\s*(?P<name>.+)'
# #     matches = re.finditer(pattern, text, re.IGNORECASE)
# #     details = []
# #     for match in matches:
# #         details.append((match.group('quantity'), match.group('unit'), match.group('name').strip()))
# #     return details


# def get_cheapest_price(products, required_quantity, unit):
#     # Convert all quantities to a standard unit before comparison
#     store_matches = []
#     for product in products:
#         product_quantity = convert_to_standard(product['quantity'], product['unit'])  # assuming 'quantity' and 'unit' are available
#         if fuzz.partial_ratio(ingredient, product['name']) > 70 and product_quantity >= required_quantity:
#             store_matches.append((product['name'], product['price'], product_quantity))

#     if store_matches:
#         # Find the product with the lowest price that meets the quantity requirement
#         cheapest = min(store_matches, key=lambda x: float(x[1]))
#         return float(cheapest[1])  # Return the price as a float
#     return None




# # Apply the extraction function to the ingredients' quantity column.
# recipes_data['ingredient_details'] = recipes_data['ingredients_quantity'].apply(extract_ingredient_details)

# # Convert ingredient quantities to a standard unit based on a conversion table.
# def convert_to_standard(quantity, unit):
#     unit_conversions = {
#         'cup': 240, 'tbsp': 15, 'tsp': 5, 'kg': 1000, 'g': 1, 'ml': 1, 'l': 1000, 'oz': 28.35, 'lb': 453.59
#     }
#     return float(quantity) * unit_conversions.get(unit, 1)

# # Find the cheapest available option for each ingredient across three stores.
# def find_cheapest_matches(woolworths_products, coles_products, aldi_products, recipe_ingredients):
#     matches = []
#     total_cost = 0
#     all_matched = True

#     for quantity, unit, ingredient in recipe_ingredients:
#         converted_quantity = convert_to_standard(quantity, unit)

#         # Inner function to determine the cheapest price for an ingredient.
#         def get_cheapest_price(products):
#             store_matches = [(p['name'], p['price']) for p in products if fuzz.partial_ratio(ingredient, p['name']) > 70 and isinstance(p['price'], str) and p['price'].replace('.', '', 1).isdigit()]
#             if store_matches:
#                 cheapest = min(store_matches, key=lambda x: float(x[1]))
#                 return float(cheapest[1])
#             return None

#         ww_price = get_cheapest_price(woolworths_products)
#         coles_price = get_cheapest_price(coles_products)
#         aldi_price = get_cheapest_price(aldi_products)

#         prices = [price for price in [ww_price, coles_price, aldi_price] if price is not None]
#         if prices:
#             cheapest_price = min(prices)
#             total_cost += cheapest_price
#         else:
#             all_matched = False

#         match_description = f"{quantity} {unit} {ingredient}: Woolworths - {ww_price if ww_price is not None else 'NONE'}, Coles - {coles_price if coles_price is not None else 'NONE'}, ALDI - {aldi_price if aldi_price is not None else 'NONE'}"
#         matches.append(match_description)

#     cost_str = f"{total_cost:.2f}" if all_matched else f"~{total_cost:.2f}"
#     return matches, cost_str

# # Prepare product details including price and store for processing.
# woolworths_data['store_product'] = woolworths_data.apply(lambda x: {'name': x['Product Name'], 'price': x['WOW Price'], 'store': 'Woolworths'}, axis=1)
# coles_data['store_product'] = coles_data.apply(lambda x: {'name': x['Product Name'], 'price': x['COL Price'], 'store': 'Coles'}, axis=1)
# aldi_data['store_product'] = aldi_data.apply(lambda x: {'name': x['Product Name'], 'price': x['Price'], 'store': 'ALDI'}, axis=1)

# # Create new recipes list with updated prices and cost estimations.
# new_recipes = []
# for index, row in recipes_data.iterrows():
#     matched_ingredients, total_cost = find_cheapest_matches(
#         woolworths_data['store_product'].tolist(),
#         coles_data['store_product'].tolist(),
#         aldi_data['store_product'].tolist(),
#         row['ingredient_details']
#     )
#     new_recipe = {
#         "recipe_id": row["recipe_id"],
#         "recipe_name": row["recipe_name"],
#         "ingredients_quantity": row["ingredients_quantity"],
#         "ingredient_matches": ', '.join(matched_ingredients),
#         "cost": total_cost,
#         "cooking_directions": row["cooking_directions"],
#         "prep_time_min": row["prep_time_min"],
#         "cook_time_min": row["cook_time_min"],
#         "total_time_min": row["total_time_min"],
#         "difficulty": row["difficulty"],
#         "rating": row["rating"],
#         "protein_g": row["protein_g"],
#         "energy_kcal": row["energy_kcal"],
#         "fat_g": row["fat_g"],
#         "saturated_fat_g": row["saturated_fat_g"],
#         "carbs_g": row["carbs_g"],
#         "sugar_g": row["sugar_g"],
#         "sodium_mg": row["sodium_mg"],
#         "classification": row["classification"],
#         "allergens": row["allergens"],
#         "image_link": row["image_link"],
#         "image": row["image"]
#     }
#     new_recipes.append(new_recipe)

# # Save the updated recipes to a JSON file.
# with open('/home/snackos12/Desktop/DECO3801 Project/Updated Recipes.json', 'w') as f:
#     json.dump(new_recipes, f, indent=4)

# print("Updated recipe JSON file created successfully with cost estimates based on cheapest ingredients.")





"""Ok this one should actually be checking properly"""
import pandas as pd
import re
import json
from fuzzywuzzy import fuzz
from fuzzywuzzy import process

# Load datasets
woolworths_data = pd.read_csv('/home/snackos12/Desktop/DECO3801 Project/Woolworths.csv')
coles_data = pd.read_csv('/home/snackos12/Desktop/DECO3801 Project/Coles.csv')
aldi_data = pd.read_csv('/home/snackos12/Desktop/DECO3801 Project/Aldi.csv')
recipes_data = pd.read_json('/home/snackos12/Desktop/DECO3801 Project/D3801 Recipes - Recipes.json')

# Normalize and ensure consistent handling of price data
woolworths_data['WOW Price'] = woolworths_data['WOW Price'].astype(str)
coles_data['COL Price'] = coles_data['COL Price'].astype(str)
aldi_data['Price'] = aldi_data['Price'].astype(str)

def extract_ingredient_details(text):
    # Regex to extract quantity, unit, and ingredient name
    pattern = r'(?P<quantity>\d+)?\s*(?P<unit>ml|g|kg|oz|lb|cup|tbsp|tsp|tablespoon|teaspoon|l)?\s*(?P<name>.+)'
    matches = re.finditer(pattern, text, re.IGNORECASE)
    details = []
    for match in matches:
        # Handle cases where quantity or unit might be missing
        quantity = match.group('quantity') if match.group('quantity') else '1'  # Default to 1 if no quantity specified
        unit = match.group('unit') if match.group('unit') else 'unit'  # Use 'unit' as a placeholder
        details.append((quantity, unit, match.group('name').strip()))
    return details

# Apply the function to extract details
recipes_data['ingredient_details'] = recipes_data['ingredients_quantity'].apply(extract_ingredient_details)

def convert_to_standard(quantity, unit):
    # Conversion dictionary for different units to a standard measurement
    unit_conversions = {
        'cup': 240, 'tbsp': 15, 'tsp': 5, 'kg': 1000, 'g': 1, 'ml': 1, 'l': 1000, 'oz': 28.35, 'lb': 453.59,
        'unit': 1  # Placeholder unit conversion, assumes a baseline quantity
    }
    return float(quantity) * unit_conversions.get(unit, 1)  # Use 1 as default if unit is not recognized

def find_cheapest_matches(woolworths_products, coles_products, aldi_products, recipe_ingredients):
    matches = []
    total_cost = 0
    all_matched = True

    for ingredient_details in recipe_ingredients:
        quantity, unit, ingredient = ingredient_details
        converted_quantity = convert_to_standard(quantity, unit)

        # Function to find the cheapest match considering measurement mismatches
        # def get_cheapest_price(products, ingredient_unit):
        #     store_matches = []
        #     for p in products:
        #         # Only compare prices for ingredients with matching names above a similarity threshold
        #         if fuzz.partial_ratio(ingredient, p['name']) > 70:
        #             # Check if unit matches or if no unit specified in the product description
        #             if ingredient_unit == 'unit' or not p.get('unit') or ingredient_unit == p.get('unit'):
        #                 store_matches.append((p['name'], float(p['price'])))
        #     return min(store_matches, key=lambda x: x[1]) if store_matches else None

        def get_cheapest_price(products, ingredient_unit):
            store_matches = []
            for p in products:
                # Ensure the price can be converted to float; if not, ignore this product
                try:
                    price = float(p['price'])
                except ValueError:
                    continue  # Skip this product if price is not a valid float

                if fuzz.partial_ratio(ingredient, p['name']) > 70:
                    if ingredient_unit == 'unit' or not p.get('unit') or ingredient_unit == p.get('unit'):
                        store_matches.append((p['name'], price))

            return min(store_matches, key=lambda x: x[1]) if store_matches else None


        # Get the cheapest prices from each store
        ww_price = get_cheapest_price(woolworths_products, unit)
        coles_price = get_cheapest_price(coles_products, unit)
        aldi_price = get_cheapest_price(aldi_products, unit)

        # Determine the cheapest price available
        prices = [price for price in [ww_price, coles_price, aldi_price] if price is not None]
        if prices:
            cheapest_price = min(prices, key=lambda x: x[1])
            total_cost += cheapest_price[1]  # Sum the lowest prices
            match_description = f"{quantity} {unit} {ingredient}: Woolworths - {ww_price[1] if ww_price else 'NONE'}, Coles - {coles_price[1] if coles_price else 'NONE'}, ALDI - {aldi_price[1] if aldi_price else 'NONE'}"
        else:
            all_matched = False
            match_description = f"{quantity} {unit} {ingredient}: No matches found"
        
        matches.append(match_description)

    # Calculate the total cost and return matches
    cost_str = f"{total_cost:.2f}" if all_matched else f"~{total_cost:.2f}"
    return matches, cost_str

# Prepare product details including price and store for easier access
woolworths_data['store_product'] = woolworths_data.apply(lambda x: {'name': x['Product Name'], 'price': x['WOW Price'], 'store': 'Woolworths'}, axis=1)
coles_data['store_product'] = coles_data.apply(lambda x: {'name': x['Product Name'], 'price': x['COL Price'], 'store': 'Coles'}, axis=1)
aldi_data['store_product'] = aldi_data.apply(lambda x: {'name': x['Product Name'], 'price': x['Price'], 'store': 'ALDI'}, axis=1)

new_recipes = []
for index, row in recipes_data.iterrows():
    matched_ingredients, total_cost = find_cheapest_matches(
        woolworths_data['store_product'].tolist(),
        coles_data['store_product'].tolist(),
        aldi_data['store_product'].tolist(),
        row['ingredient_details']
    )
    new_recipe = {
        "recipe_id": row["recipe_id"],
        "recipe_name": row["recipe_name"],
        "ingredients_quantity": row["ingredients_quantity"],
        "ingredient_matches": ', '.join(matched_ingredients),
        "cost": total_cost,
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

# Write to a new JSON file
with open('/home/snackos12/Desktop/DECO3801 Project/Updated Recipes.json', 'w') as f:
    json.dump(new_recipes, f, indent=4)

print("Updated recipe JSON file created successfully with cost estimates based on cheapest ingredients.")

