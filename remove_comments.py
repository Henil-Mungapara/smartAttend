import os
import re

def remove_comments_from_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Regex to handle block comments
    # Replaces block comments with empty string
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)

    # Regex to handle line comments:
    # 1. Matches string literals (captures inside quotes)
    # 2. Or matches // and rest of the line (no group capture)
    # If group 1 (string) exists, keep it. Otherwise, return empty.
    
    pattern = r'(".*?"|\'.*?\')|(//[^\n]*)'
    
    def replacer(match):
        if match.group(1) is not None:
            return match.group(1) # It was a string literal, keep it!
        else:
            return "" # It was a comment, remove it!

    content = re.sub(pattern, replacer, content)

    # Clean up excessive empty lines
    content = re.sub(r'\n\s*\n\s*\n', '\n\n', content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

def main():
    directory = 'lib'
    for root, dirs, files in os.walk(directory):
        for filename in files:
            if filename.endswith(".dart"):
                filepath = os.path.join(root, filename)
                remove_comments_from_file(filepath)
                # print(f"Cleaned {filepath}")
                
if __name__ == '__main__':
    main()
