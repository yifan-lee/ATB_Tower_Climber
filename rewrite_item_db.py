import re

with open("config/item_db.gd", "r") as f:
    content = f.read()

# I will use a simple regex to capture the whole argument block.
# Item.new().setup(...)
def repl(m):
    block = m.group(1)
    # The block contains all arguments separated by commas, but wait, string literals might have commas.
    # We can split by commas that are not inside quotes.
    
    parts = []
    current = ""
    in_str = False
    for char in block:
        if char == '"':
            in_str = not in_str
        if char == ',' and not in_str:
            parts.append(current)
            current = ""
        else:
            current += char
    parts.append(current)
    
    parts = [p.strip() for p in parts]
    
    id_arg = parts[0]
    n_arg = parts[1]
    t_arg = parts[2]
    hp_arg = parts[3]
    mp_arg = parts[4]
    desc_arg = parts[5]
    
    atk_arg = parts[6] if len(parts) > 6 else "0"
    def_arg = parts[7] if len(parts) > 7 else "0"
    spd_arg = parts[8] if len(parts) > 8 else "0"
    slot_arg = parts[9] if len(parts) > 9 else "Item.EquipSlot.NONE"
    
    new_call = f'{id_arg}, {n_arg}, {t_arg}, {desc_arg}, {slot_arg}, {hp_arg}, {mp_arg}, {atk_arg}, {def_arg}, {spd_arg}'
    
    return f'Item.new().setup(\n\t\t{new_call}\n\t)'

new_content = re.sub(r'Item\.new\(\)\.setup\((.*?)\)', repl, content, flags=re.DOTALL)

with open("config/item_db.gd", "w") as f:
    f.write(new_content)
