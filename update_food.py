
import re
import os
import random

filepath = r'c:\Users\carlos\Zomboid\Workshop\S4Economy_ZEnicko_Version\Contents\mods\S4EcoPack\common\media\lua\shared\S4_Shop_Data.lua'

with open(filepath, 'r') as f:
    content = f.read()

def update_food(match):
    full_type = match.group(1)
    props = match.group(2)
    
    cat_match = re.search(r'Category\s*=\s*"Food"', props)
    if not cat_match:
        return f'S4_Shop_Data["{full_type}"] = {{{props}}}'
    
    # Increase BuyPrice by 100% (multiply by 2)
    def double_price(p_match):
        price = int(p_match.group(2))
        return f'{p_match.group(1)}{price * 2}'
    
    props = re.sub(r'(BuyPrice\s*=\s*)(\d+)', double_price, props)
    
    # Set Stock to 1 or 2
    new_stock = random.randint(1, 2)
    # Use \g<1> to avoid ambiguity with group numbers
    props = re.sub(r'(Stock\s*=\s*)(\d+)', rf'\g<1>{new_stock}', props)
    
    return f'S4_Shop_Data["{full_type}"] = {{{props}}}'

new_content = re.sub(r'S4_Shop_Data\["(.*?)"\]\s*=\s*\{(.*?)\}', update_food, content, flags=re.DOTALL)

with open(filepath, 'w') as f:
    f.write(new_content)

print("Food prices doubled and stock limited.")
