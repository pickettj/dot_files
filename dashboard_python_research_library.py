#!/usr/bin/env python3
"""
Research Library Dashboard - Shows available custom libraries
"""

from pathlib import Path

# Get the Projects directory
projects_dir = Path(__file__).parent.parent

# Your custom libraries
libraries = {
    "Database Queries": projects_dir / "database/database_query_functions.py",
    "Persian Dictionary": projects_dir / "persian_dictionary/dictionary_queries.py",
    "Central Asia Plain Text Corpus": projects_dir / "eurasia_corpus_tool/historical_corpus_plain_text.py",
    "Pahlavi Corpus": projects_dir / "pahlavi_digital_projects/pahlavi_corpus_tool.py",
}

# Display the libraries
print("\n" + "=" * 70)
print("🏛️  RESEARCH LIBRARY DASHBOARD")
print("=" * 70)

for i, (name, path) in enumerate(libraries.items(), 1):
    # Check if file exists
    status = "✅" if path.exists() else "❌"
    
    # Define custom keywords/acronyms
    keywords = {
        "Database Queries": "hdb",
        "Persian Dictionary": "perd", 
        "Central Asia Plain Text Corpus": "hcorp",
        "Pahlavi Corpus": "pcorp"
    }
    keyword = keywords.get(name, name.split()[0].lower())
    
    # Display with number, status, keyword, and clean formatting
    print(f"{i}. {status} {name} (\"{keyword}\")")
    print(f"   📁 {path}")
    print()

print("=" * 70)
print("🐍 Python REPL ready - import as needed!")
print("=" * 70)

# Import function
def load_libs(*keywords):
   """Load libraries by keyword: load_libs('hdb', 'perd')"""
   import importlib.util
   import sys
   import inspect
   
   # Define custom keywords/acronyms
   keyword_map = {
       "hdb": "Database Queries",
       "perd": "Persian Dictionary", 
       "hcorp": "Central Asia Plain Text Corpus",
       "pcorp": "Pahlavi Corpus"
   }
   
   for keyword in keywords:
       # Map keyword to library name
       lib_name = keyword_map.get(keyword.lower())
       if not lib_name:
           print(f"❌ No library found for keyword: '{keyword}'")
           print(f"Available keywords: {list(keyword_map.keys())}")
           continue
           
       lib_path = libraries[lib_name]
       
       try:
           # Create alias from keyword
           alias = keyword.lower()
           
           # ADD THIS: Add the module's directory to Python path
           module_dir = str(lib_path.parent)
           if module_dir not in sys.path:
               sys.path.insert(0, module_dir)
           
           # Load the module
           spec = importlib.util.spec_from_file_location(lib_name, lib_path)
           module = importlib.util.module_from_spec(spec)
           spec.loader.exec_module(module)
           
           # Add to global namespace with alias
           globals()[alias] = module
           
           print(f"\n✅ Successfully loaded: {lib_name}")
           print(f"🏷️  Available as: {alias}")
           print(f"💡 Usage: {alias}.function_name()")
           
           # List functions with docstrings
           functions = [name for name in dir(module) 
                      if callable(getattr(module, name)) and not name.startswith('_')]
           
           if functions:
               print(f"📋 Available functions ({len(functions)}):")
               for func_name in functions:
                   func = getattr(module, func_name)
                   
                   # Get function signature
                   try:
                       sig = inspect.signature(func)
                       func_signature = f"{alias}.{func_name}{sig}"
                   except:
                       func_signature = f"{alias}.{func_name}()"
                   
                   # Get docstring
                   docstring = func.__doc__
                   if docstring:
                       first_line = docstring.strip().split('\n')[0]
                       print(f"   • {func_signature} - {first_line}")
                   else:
                       print(f"   • {func_signature}")
           else:
               print("   No functions found in this module")
               
       except Exception as e:
           print(f"❌ Failed to load {lib_name}: {str(e)}")

print("\n💡 Quick start: Try 'load_libs(\"hdb\")' to load your libraries!")
print("💡 Use load_libs('perd', 'hdb') to load multiple at once!")