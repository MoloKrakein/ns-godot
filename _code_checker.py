import os
import datetime

# --- CONFIGURATION ---
# The folders you want to completely ignore
EXCLUDE_FOLDERS = ['addons', '.godot', '.git']

# The dedicated folder where the resulting .txt files will be saved
OUTPUT_FOLDER = 'Exported_Code_Logs'

# The output files that will be generated inside the output folder
SCRIPT_OUTPUT = os.path.join(OUTPUT_FOLDER, 'combined_scripts.txt')
SCENE_OUTPUT = os.path.join(OUTPUT_FOLDER, 'combined_scenes.txt')
# ---------------------

def write_to_file(filepath, out_file):
    """Helper function to format the file content neatly with timestamps."""
    # Get the last modified time of the file
    try:
        timestamp = os.path.getmtime(filepath)
        last_modified = datetime.datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M:%S')
    except Exception:
        last_modified = "Unknown Date"

    out_file.write(f"\n{'='*60}\n")
    out_file.write(f"--- FILE: {filepath} ---\n")
    out_file.write(f"--- LAST MODIFIED: {last_modified} ---\n")
    out_file.write(f"{'='*60}\n\n")
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            out_file.write(f.read())
            out_file.write("\n")
    except Exception as e:
        out_file.write(f"[ERROR READING FILE: {e}]\n")

def main():
    print("Starting to scan Godot project...")
    
    # Create the output folder if it doesn't already exist
    os.makedirs(OUTPUT_FOLDER, exist_ok=True)
    
    # Open both output files in write mode
    with open(SCRIPT_OUTPUT, 'w', encoding='utf-8') as script_file, \
         open(SCENE_OUTPUT, 'w', encoding='utf-8') as scene_file:
             
        # Walk through the directory
        for root, dirs, files in os.walk('.'):
            
            # Remove excluded directories AND the output folder so os.walk ignores them completely
            dirs[:] = [d for d in dirs if d not in EXCLUDE_FOLDERS and d != OUTPUT_FOLDER]
            
            for file in files:
                filepath = os.path.join(root, file)
                
                # If it's a GDScript file, add it to the script txt
                if file.endswith('.gd'):
                    write_to_file(filepath, script_file)
                    
                # If it's a Godot Scene file, add it to the scene txt
                elif file.endswith('.tscn'):
                    write_to_file(filepath, scene_file)

    print(f"Success! Created files inside the '{OUTPUT_FOLDER}' folder.")

if __name__ == '__main__':
    main()