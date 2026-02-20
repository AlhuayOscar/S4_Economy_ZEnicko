
import re
import os

filepath = r'c:\Users\carlos\Zomboid\Workshop\S4Economy_ZEnicko_Version\Contents\mods\S4EcoPack\common\media\lua\shared\S4_Shop_Data.lua'

with open(filepath, 'r') as f:
    content = f.read()

# Revised patterns with more specific keywords to avoid "everything in everything"
patterns = {
    'HandGun': [
        'Pistol', 'Revolver', 'M1911', 'Glock', 'Magnum', 'Deagle', 'Beretta', 'M9', '38Special', 
        '44Magnum', '45Auto', '357Sig', 'Snubnose', 'Deringer'
    ],
    'Rifle': [
        'AssaultRifle', 'M14', 'M16', 'AK47', 'SKS', 'Sniper', 'HuntingRifle', 'VarmintRifle', 
        'Carbine', 'M1Garand', 'FAL', 'G3', 'Mauser', 'Winchester', 'BoltAction'
    ],
    'Shotgun': [
        'Shotgun', 'DoubleBarrel', 'JS2000', 'ActionShotgun', 'SawedOff', 'PumpShotgun'
    ],
    'Ammo': [
        'Bullets', 'Shells', 'Clip', 'Magazine', 'Carton', 'Box9mm', 'Box.44', 'Box.45', 'Box.223', 
        'Box.308', 'Box.556', 'BoxShotgun', 'Round9mm', 'Round45', 'Round308', 'Round556'
    ],
    'Tools': [
        'Hammer', 'Screwdriver', 'Saw', 'Axe', 'Crowbar', 'Wrench', 'Shovel', 'PickAxe', 'Toolbox', 
        'Welding', 'Propane', 'BlowTorch', 'Anvil', 'Bellows', 'Pick', 'Wire', 'MetalPipe', 
        'SheetMetal', 'ScrapMetal', 'Nails', 'Screws', 'Glue', 'DuctTape'
    ],
    'Medical': [
        'Bandage', 'Alcohol', 'Disinfectant', 'Suture', 'Syringe', 'FirstAid', 'Splint', 
        'Antibiotic', 'Health', 'Gauze', 'Cotton', 'Adhesive', 'Medical'
    ],
    'VehicleParts': [
        'Tire', 'Engine', 'CarBattery', 'Muffler', 'Brakes', 'Suspension', 'CarDoor', 'Windshield', 
        'Heater', 'GasTank', 'Wheel', 'Valves'
    ],
    'GunParts': [
        'Sling', 'Scope', 'Laser', 'Silencer', 'Suppressor', 'RecoilPad', 'Fiberglass', 'Choke', 
        'GunPart'
    ],
    'Clothing': [
        'Armor', 'Vest', 'Helmet', 'Gloves', 'Boots', 'Pants', 'Shirt', 'Jacket', 'Coat', 'Hat', 
        'Mask', 'Socks', 'Shoes', 'Belt', 'Dress', 'Skirt', 'Trousers'
    ],
    'Books': [
        'Book', 'Magazine', 'Newspaper', 'Manual', 'Map', 'Recipe', 'Journal', 'Brochure'
    ],
    'Food': [
        'Water', 'Soda', 'Apple', 'Beef', 'Soup', 'Canned', 'Juice', 'Beer', 'Wine', 'Cookie', 
        'Bread', 'Chocolate', 'Crisps', 'MRE', 'Steak', 'Ham', 'Cheese', 'Milk', 'Egg'
    ]
}

# Items that should be categorized as Medical but have Restock = 1 (Drugs)
drug_keywords = [
    'DrugsDLC', 'DrugMod', 'Xanax', 'Tramadol', 'Codeine', 'Morphine', 'Acid', 'Shroom', 'Needle', 
    'Clonazepam', 'Tylenol', 'Bismuth', 'Narcan'
]

def process_item(match):
    full_type = match.group(1)
    props = match.group(2)
    
    # 1. Determine Category
    new_cat = "Etc"
    
    # Heuristic matching based on FullType
    found = False
    
    # Check Drug Keywords first to force Medical+Restock1
    is_drug = False
    for dkw in drug_keywords:
        if dkw.lower() in full_type.lower():
            new_cat = "Medical"
            is_drug = True
            found = True
            break
    
    if not found:
        for cat, keywords in patterns.items():
            for kw in keywords:
                # Use word boundaries or strict matching if possible to avoid "everything in everything"
                # Here we use lowercase check
                if kw.lower() in full_type.lower():
                    new_cat = cat
                    found = True
                    break
            if found: break
            
    # Overwrite category in props
    props = re.sub(r'Category\s*=\s*".*?"', f'Category      = "{new_cat}"', props)
    
    # 2. Extract current stock and restock
    stock_match = re.search(r'Stock\s*=\s*(\d+)', props)
    restock_match = re.search(r'Restock\s*=\s*(\d+)', props)
    
    current_stock = int(stock_match.group(1)) if stock_match else 0
    current_restock = int(restock_match.group(1)) if restock_match else 0
    
    # Apply Cap at 300
    new_stock = min(current_stock, 300)
    
    # Apply Restock Rules
    new_restock = current_restock
    
    if is_drug:
        new_restock = 1
    elif new_cat == "Medical":
        # Restore normal medical restock if it was set to 1 by previous script
        if current_restock == 1:
            new_restock = 25
            new_stock = 100
    elif new_cat == "Food":
        # Keep food scarcity (already applied)
        pass

    # Replace in props
    props = re.sub(r'(Stock\s*=\s*)(\d+)', rf'\g<1>{new_stock}', props)
    props = re.sub(r'(Restock\s*=\s*)(\d+)', rf'\g<1>{new_restock}', props)
        
    return f'S4_Shop_Data["{full_type}"] = {{{props}}}'

# Match entire block
new_content = re.sub(r'S4_Shop_Data\["(.*?)"\]\s*=\s*\{(.*?)\}', process_item, content, flags=re.DOTALL)

with open(filepath, 'w') as f:
    f.write(new_content)

print("Finished fixing categories and specific restock rules.")
