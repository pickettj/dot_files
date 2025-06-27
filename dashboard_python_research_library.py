#!/usr/bin/env python3

"""
Research Library Dashboard - Shows available custom libraries
"""

from pathlib import Path

# get Project directory

#projects_dir = Path(__file__).parent.parent
# hard-coded path for debugging purposes
projects_dir = Path("/Users/pickettj/Projects")

# confirm that pathlib is working:
# print (projects_dir)

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
    
    # Display with number, status, and clean formatting
    print(f"{i}. {status} {name}")
    print(f"   📁 {path}")
    print()

print("=" * 70)
print("🐍 Python REPL ready - import as needed!")
print("=" * 70)
