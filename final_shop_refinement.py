
import re
import os

filepath = r'c:\Users\carlos\Zomboid\Workshop\S4Economy_ZEnicko_Version\Contents\mods\S4EcoPack\common\media\lua\shared\S4_Shop_Data.lua'

with open(filepath, 'r') as f:
    content = f.read()

# Refined category keywords - even more strict
patterns = {
    'HandGun': [
        'Pistol', 'Revolver', 'M1911', 'Glock', 'Magnum', 'Deagle', 'Beretta', 'M9', '38Special', 
        '44Magnum', '45Auto', '357Sig', 'Snubnose', 'Deringer', 'DesertEagle'
    ],
    'Rifle': [
        'AssaultRifle', 'M14', 'M16', 'AK47', 'SKS', 'Sniper', 'HuntingRifle', 'VarmintRifle', 
        'Carbine', 'M1Garand', 'FAL', 'G3', 'Mauser', 'Winchester', 'BoltAction', 'LMG', 'SMG', 'MP5'
    ],
    'Shotgun': [
        'Shotgun', 'DoubleBarrel', 'JS2000', 'ActionShotgun', 'SawedOff', 'PumpShotgun'
    ],
    'Ammo': [
        'Bullets', 'Shells', 'Clip', 'Magazine', 'Carton', 'Box9mm', 'Box.44', 'Box.45', 'Box.223', 
        'Box.308', 'Box.556', 'BoxShotgun', 'Round9mm', 'Round45', 'Round308', 'Round556', 'Ammo'
    ],
    'Tools': [
        'Hammer', 'Screwdriver', 'Saw', 'Axe', 'Crowbar', 'Wrench', 'Shovel', 'PickAxe', 'Toolbox', 
        'Welding', 'Propane', 'BlowTorch', 'Anvil', 'Bellows', 'Pick', 'Wire', 'MetalPipe', 
        'SheetMetal', 'ScrapMetal', 'Nails', 'Screws', 'Glue', 'DuctTape', 'Solder', 'Battery', 
        'Controller', 'Radio', 'Circuit', 'Electronic', 'Screws', 'PipeWrench'
    ],
    'Medical': [
        'Bandage', 'Alcohol', 'Disinfectant', 'Suture', 'Syringe', 'FirstAid', 'Splint', 
        'Antibiotic', 'Health', 'Gauze', 'Cotton', 'Adhesive', 'Medical'
    ],
    'VehicleParts': [
        'Tire', 'Engine', 'CarBattery', 'Muffler', 'Brakes', 'Suspension', 'CarDoor', 'Windshield', 
        'Heater', 'GasTank', 'Wheel', 'Valves', 'Jack', 'GasCan'
    ],
    'GunParts': [
        'Sling', 'Scope', 'Laser', 'Silencer', 'Suppressor', 'RecoilPad', 'Fiberglass', 'Choke', 
        'GunPart', 'Sight'
    ],
    'Clothing': [
        'Armor', 'Vest', 'Helmet', 'Gloves', 'Boots', 'Pants', 'Shirt', 'Jacket', 'Coat', 'Hat', 
        'Mask', 'Socks', 'Shoes', 'Belt', 'Dress', 'Skirt', 'Trousers', 'Cap', 'Glasses'
    ],
    'Books': [
        'Book', 'Magazine', 'Newspaper', 'Manual', 'Map', 'Recipe', 'Journal', 'Brochure', 'Comic'
    ],
    'Food': [
        'Water', 'Soda', 'Apple', 'Beef', 'Soup', 'Canned', 'Juice', 'Beer', 'Wine', 'Cookie', 
        'Bread', 'Chocolate', 'Crisps', 'MRE', 'Steak', 'Ham', 'Cheese', 'Milk', 'Egg', 'Fish', 
        'Meat', 'Sugar', 'Salt', 'Coffee', 'Tea', 'LunchBox'
    ]
}

# Recreationals - Restock 1
drug_keywords = [
    'DrugsDLC', 'DrugMod', 'Xanax', 'Tramadol', 'Codeine', 'Morphine', 'Acid', 'Shroom', 
    'Clonazepam', 'Bismuth', 'Narcan'
]

def process_item(match):
    full_type = match.group(1)
    props = match.group(2)
    
    # 1. Determine Category
    new_cat = "Etc"
    found = False
    
    # Check Drug Keywords first
    is_recreational = False
    for dkw in drug_keywords:
        if dkw.lower() in full_type.lower():
            new_cat = "Medical"
            is_recreational = True
            found = True
            break
    
    if not found:
        # Check others
        for cat, keywords in patterns.items():
            for kw in keywords:
                if kw.lower() in full_type.lower():
                    new_cat = cat
                    found = True
                    break
            if found: break
            
    # Overwrite category in props
    props = re.sub(r'Category\s*=\s*".*?"', f'Category      = "{new_cat}"', props)
    
    # 2. Cap Stock at 300
    def stock_cap(s_match):
        stock_val = int(s_match.group(2))
        return f'{s_match.group(1)}{min(stock_val, 300)}'
    props = re.sub(r'(Stock\s*=\s*)(\d+)', stock_cap, props)
    
    # 3. Restock Rule
    if is_recreational:
        props = re.sub(r'(Restock\s*=\s*)(\d+)', r'\g<1>1', props)
    elif new_cat == "Medical":
        # Standardize real medical restock (e.g. 15 for bandages)
        props = re.sub(r'(Restock\s*=\s*)(\d+)', r'\g<1>15', props)
        # Also ensure they have some stock if it was too low
        def reset_medical_stock(s_match):
            val = int(s_match.group(2))
            return f'{s_match.group(1)}{max(val, 50)}'
        props = re.sub(r'(Stock\s*=\s*)(\d+)', reset_medical_stock, props)
    elif new_cat == "Food":
        # Keep food logic as it was (scarcity applied earlier)
        pass

    return f'S4_Shop_Data["{full_type}"] = {{{props}}}'

# Match entire block
new_content = re.sub(r'S4_Shop_Data\["(.*?)"\]\s*=\s*\{(.*?)\}', process_item, content, flags=re.DOTALL)

with open(filepath, 'w') as f:
    f.write(new_content)

print("Finished refining categories, capping stocks at 300, and protecting medical supplies.")
