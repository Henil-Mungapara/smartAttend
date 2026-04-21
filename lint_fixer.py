import os
import re

lib_path = r"c:\Users\munga\smartAttend\lib\Admin_Dashboard"

for root, _, files in os.walk(lib_path):
    for filename in files:
        if not filename.endswith('.dart'):
            continue
            
        file_path = os.path.join(root, filename)
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        changed = False

        # 1. Unused imports (specifically smartattend/Admin_Dashboard/Admin_Main_Navigation_Screen.dart in View_Department_Screen.dart)
        if "warning - Unused import:" in content or True:
            # We will just regex matching for known unused imports
            new_content = re.sub(r"import 'package:smartattend/Admin_Dashboard/Admin_Main_Navigation_Screen\.dart';\n", "", content)
            if new_content != content:
                content = new_content
                changed = True

        # 2. value to initialValue
        new_content = re.sub(r"value:\s*(items\.any\([^)]+\)\s*\?\s*value\s*:\s*null),", r"initialValue: \1,", content)
        if new_content != content:
            content = new_content
            changed = True

        # 3. Unused variables
        new_content = re.sub(r"\s*final\s+screenWidth\s*=\s*AppSize\.width\(context\);\n?", "", content)
        new_content = re.sub(r"\s*final\s+screenHeight\s*=\s*AppSize\.height\(context\);\n?", "", content)
        new_content = re.sub(r"\s*double\s+w\s*=\s*AppSize\.width\(context\);\n?", "", content)
        new_content = re.sub(r"\s*double\s+h\s*=\s*AppSize\.height\(context\);\n?", "", content)
        if new_content != content:
            content = new_content
            changed = True

        # 4. use_build_context_synchronously -> UIHelper.showSnackBar(context, ...) -> we add if(!mounted) return;
        # Instead of parsing, we can just replace the direct calls to UIHelper.showSnackBar that follow await
        # A safer pattern is replacing Navigator.pop(context); with if(mounted) Navigator.pop(context);
        # Wait, if we use `mounted`, it must be inside State class. It usually is.
        
        # Let's add if (!mounted) return; before UIHelper or Navigator if missing
        
        def insert_mounted_check(match):
            prefix = match.group(1)
            call = match.group(2)
            if "mounted" in prefix:
                return match.group(0)
            return prefix + "if (!mounted) return;\n" + " " * (len(prefix) - prefix.rfind('\n') - 1) + call

        # We look for blocks like: await ...; \n UIHelper.showSnackBar(context,
        # It's tricky to write a perfect regex for this.
        # Let's manually replace `Navigator.pop(context);` with `if (mounted) { Navigator.pop(context); }`
        new_content = re.sub(r"([ \t]*)Navigator\.pop\(context\);", r"\1if (mounted) Navigator.pop(context);", content)
        new_content = re.sub(r"([ \t]*)UIHelper\.showSnackBar\(context,\s*([^)]+)\);", r"\1if (mounted) UIHelper.showSnackBar(context, \2);", new_content)
        # Avoid duplicate mounted checks
        new_content = re.sub(r"if\s*\(!mounted\)\s*return;\s*if\s*\(mounted\)", "if (!mounted) return;", new_content)
        new_content = re.sub(r"if\s*\(mounted\)\s*if\s*\(mounted\)", "if (mounted)", new_content)

        if new_content != content:
            content = new_content
            changed = True

        # 5. .withOpacity -> .withAlpha
        def opacity_to_alpha(match):
            color = match.group(1)
            opacity_val = float(match.group(2))
            alpha_val = int(opacity_val * 255)
            # Flutter 3.24 allows .withAlpha directly, but Colors.black.withAlpha may already be valid
            return f"{color}.withAlpha({alpha_val})"

        new_content = re.sub(r"(Color\([^)]+\)|Colors\.[a-zA-Z0-9_]+)\.withOpacity\(((?:0\.[0-9]+)|1(?:\.0+)?)\)", opacity_to_alpha, content)
        if new_content != content:
             content = new_content
             changed = True

        # 6. WillPopScope
        if "WillPopScope" in content:
            new_content = content.replace("WillPopScope(", "PopScope(").replace("onWillPop: () async {", "canPop: false, onPopInvokedWithResult: (didPop, _) async { if (didPop) return;").replace("return false;", "")
            # PopScope requires a bool canPop instead of bool returned from onWillPop. 
            # We instead handle it specifically for Admin_Main_Navigation_Screen.dart later or leave it.
            # I will skip automated complete PopScope replacements and do it manually if needed, it's safer.
            pass

        if changed:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
                print(f"Updated: {file_path}")

print("Lint fix sweep completed.")
