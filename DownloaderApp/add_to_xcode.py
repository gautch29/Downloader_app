#!/usr/bin/env python3
import uuid
import re

# Read the project file
with open('DownloaderApp.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Generate unique IDs (24 hex characters)
def gen_id():
    return ''.join([format(ord(c), 'X') for c in str(uuid.uuid4())[:12]]).upper()

# Files to add with their paths
files = [
    ('Series.swift', 'DownloaderApp/Models/Series.swift', 'Models'),
    ('SeriesService.swift', 'DownloaderApp/Services/SeriesService.swift', 'Services'),
    ('SeriesViewModel.swift', 'DownloaderApp/ViewModels/SeriesViewModel.swift', 'ViewModels'),
    ('SeriesSearchView.swift', 'DownloaderApp/Views/Series/SeriesSearchView.swift', 'Series'),
    ('SeriesDetailView.swift', 'DownloaderApp/Views/Series/SeriesDetailView.swift', 'Series'),
]

# Generate IDs for each file
file_refs = {}
build_files = {}
for filename, path, group in files:
    file_refs[filename] = gen_id()
    build_files[filename] = gen_id()

# 1. Add PBXBuildFile section entries
build_file_section = "/* Begin PBXBuildFile section */"
build_file_entries = []
for filename in files:
    fname = filename[0]
    build_id = build_files[fname]
    ref_id = file_refs[fname]
    build_file_entries.append(f"\t\t{build_id} /* {fname} in Sources */ = {{isa = PBXBuildFile; fileRef = {ref_id} /* {fname} */; }};")

# Insert after the last existing build file entry
insert_pos = content.find("/* End PBXBuildFile section */")
content = content[:insert_pos] + "\n".join(build_file_entries) + "\n\t\t" + content[insert_pos:]

# 2. Add PBXFileReference section entries
file_ref_section = "/* Begin PBXFileReference section */"
file_ref_entries = []
for filename, path, group in files:
    fname = filename
    ref_id = file_refs[fname]
    file_ref_entries.append(f"\t\t{ref_id} /* {fname} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {fname}; sourceTree = \"<group>\"; }};")

# Insert after the last existing file reference entry
insert_pos = content.find("/* End PBXFileReference section */")
content = content[:insert_pos] + "\n".join(file_ref_entries) + "\n\t\t" + content[insert_pos:]

# 3. Add to PBXGroup sections
# Add Series.swift to Models group (89178667549452CF16F0DABF)
models_group_pattern = r'(89178667549452CF16F0DABF /\* Models \*/ = \{[^}]+children = \([^)]+)'
models_match = re.search(models_group_pattern, content, re.DOTALL)
if models_match:
    insert_text = f"\n\t\t\t\t{file_refs['Series.swift']} /* Series.swift */,"
    content = content[:models_match.end()] + insert_text + content[models_match.end():]

# Add SeriesService.swift to Services group (F8D9F194C6E8D952D1E11C35)
services_group_pattern = r'(F8D9F194C6E8D952D1E11C35 /\* Services \*/ = \{[^}]+children = \([^)]+)'
services_match = re.search(services_group_pattern, content, re.DOTALL)
if services_match:
    insert_text = f"\n\t\t\t\t{file_refs['SeriesService.swift']} /* SeriesService.swift */,"
    content = content[:services_match.end()] + insert_text + content[services_match.end():]

# Add SeriesViewModel.swift to ViewModels group (932AD4F5AE6B9226D18E7611)
viewmodels_group_pattern = r'(932AD4F5AE6B9226D18E7611 /\* ViewModels \*/ = \{[^}]+children = \([^)]+)'
viewmodels_match = re.search(viewmodels_group_pattern, content, re.DOTALL)
if viewmodels_match:
    insert_text = f"\n\t\t\t\t{file_refs['SeriesViewModel.swift']} /* SeriesViewModel.swift */,"
    content = content[:viewmodels_match.end()] + insert_text + content[viewmodels_match.end():]

# Create Series group and add to Views
series_group_id = gen_id()
series_group = f'''\t\t{series_group_id} /* Series */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{file_refs['SeriesSearchView.swift']} /* SeriesSearchView.swift */,
\t\t\t\t{file_refs['SeriesDetailView.swift']} /* SeriesDetailView.swift */,
\t\t\t);
\t\t\tpath = Series;
\t\t\tsourceTree = "<group>";
\t\t}};
'''

# Insert Series group before Movies group
movies_group_pos = content.find('8748C644739E273BB62F4CD4 /* Movies */ = {')
content = content[:movies_group_pos] + series_group + "\t\t" + content[movies_group_pos:]

# Add Series group reference to Views group (9B349A59D9A8626A27783AC7)
views_group_pattern = r'(9B349A59D9A8626A27783AC7 /\* Views \*/ = \{[^}]+children = \([^)]+8748C644739E273BB62F4CD4 /\* Movies \*/,)'
views_match = re.search(views_group_pattern, content, re.DOTALL)
if views_match:
    insert_text = f"\n\t\t\t\t{series_group_id} /* Series */,"
    content = content[:views_match.end()] + insert_text + content[views_match.end():]

# 4. Add to Sources build phase (FA5D87D555F7D17824329C20)
sources_phase_pattern = r'(FA5D87D555F7D17824329C20 /\* Sources \*/ = \{[^}]+files = \([^)]+)'
sources_match = re.search(sources_phase_pattern, content, re.DOTALL)
if sources_match:
    insert_lines = []
    for filename in files:
        fname = filename[0]
        build_id = build_files[fname]
        insert_lines.append(f"\t\t\t\t{build_id} /* {fname} in Sources */,")
    insert_text = "\n" + "\n".join(insert_lines)
    content = content[:sources_match.end()] + insert_text + content[sources_match.end():]

# Write the modified content
with open('DownloaderApp.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("Successfully added Series files to Xcode project!")
