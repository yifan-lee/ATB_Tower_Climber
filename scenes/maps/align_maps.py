import os
import re

def process_gd_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Find map_data = [ ... ]
    match = re.search(r'(map_data\s*=\s*\[)(.*?)(\n\t*\])', content, re.DOTALL)
    if not match:
        return
        
    prefix = match.group(1)
    body = match.group(2)
    suffix = match.group(3)
    
    lines = body.split('\n')
    
    rows = []
    row_indices = []
    
    for i, line in enumerate(lines):
        line_stripped = line.strip()
        if not line_stripped.startswith('['):
            continue
            
        elements = re.findall(r'"([^"]*)"', line_stripped)
        if elements:
            cleaned = [e.strip() for e in elements]
            rows.append(cleaned)
            row_indices.append(i)
            
    if not rows:
        return
        
    # calculate column widths
    max_cols = max(len(r) for r in rows)
    col_widths = [0] * max_cols
    
    for r in rows:
        for c, val in enumerate(r):
            col_widths[c] = max(col_widths[c], len(val))
            
    # rebuild lines
    for r_idx, r in enumerate(rows):
        formatted_items = []
        for c, val in enumerate(r):
            padded_val = val.ljust(col_widths[c])
            formatted_items.append(f'"{padded_val}"')
            
        new_line = "\t\t[" + ", ".join(formatted_items) + "],"
        lines[row_indices[r_idx]] = new_line
        
    new_body = '\n'.join(lines)
    new_content = content[:match.start(0)] + prefix + new_body + suffix + content[match.end(0):]
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    return False

def main():
    dir_path = os.path.dirname(os.path.abspath(__file__))
    for file in os.listdir(dir_path):
        if file.endswith('.gd'):
            changed = process_gd_file(os.path.join(dir_path, file))
            if changed:
                print(f"Aligned map_data in {file}")

if __name__ == '__main__':
    main()
