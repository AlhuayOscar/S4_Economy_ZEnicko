import re
import random
import shutil
import os

# === CONFIG ===
LUA_FILE = "S4_Shop_Data.lua"
BACKUP_FILE = "S4_Shop_Data.backup.lua"

INC_FILE = "Economia_incrementada.txt"
STABLE_FILE = "Economia_estabilizada.txt"

MIN_INC = 5     # 
MAX_INC = 25    # 

# =========================
def increment_economy():
    if not os.path.exists(BACKUP_FILE):
        shutil.copy(LUA_FILE, BACKUP_FILE)

    with open(LUA_FILE, "r", encoding="utf-8") as f:
        content = f.read()

    increments = []

    def replace_buy(match):
        price = int(match.group(1))
        inc = random.randint(MIN_INC, MAX_INC)
        new_price = int(price * (1 + inc / 100))
        increments.append(inc)
        return f"BuyPrice      = {new_price}"

    content = re.sub(
        r'BuyPrice\s*=\s*(\d+)',
        replace_buy,
        content
    )

    with open(LUA_FILE, "w", encoding="utf-8") as f:
        f.write(content)

    avg_inc = sum(increments) // len(increments)

    with open(INC_FILE, "w", encoding="utf-8") as f:
        f.write(f"Economia incrementada +{avg_inc}\n")

    if os.path.exists(STABLE_FILE):
        os.remove(STABLE_FILE)

    print(f"✔ Economia incrementada (+{avg_inc})")


def stabilize_economy():
    if not os.path.exists(BACKUP_FILE):
        print("❌ No existe backup para restaurar")
        return

    shutil.copy(BACKUP_FILE, LUA_FILE)
    os.remove(BACKUP_FILE)

    with open(STABLE_FILE, "w", encoding="utf-8") as f:
        f.write("Economia estabilizada\n")

    if os.path.exists(INC_FILE):
        os.remove(INC_FILE)

    print("✔ Economia restaurada y estabilizada")


# =========================
# MAIN
if os.path.exists(INC_FILE):
    stabilize_economy()
else:
    increment_economy()
