#!/bin/bash

# 1. remove spaces (
tree -if --noreport | sort -r | grep " " | awk -f clean_filenames.awk | bash

# 2. clean accented characters - it could be necessary to repeat this step until all folder/subfolder/.../file would be
# completed cleared.

tree -if --noreport > _original.txt && \
tree -if --noreport | iconv -f utf8 -t ascii//TRANSLIT > _translittered.txt && \
diff --unchanged-line-format= --old-line-format= --new-line-format="%L" _translittered.txt _original.txt | \
sort -r | \
awk 'BEGIN{} {safe_spazi=$0; gsub(/ /,"\\ ",safe_spazi); \
command=sprintf("mv %s \"$(echo \"%s\" | iconv -f utf8 -t ascii//TRANSLIT)\"",safe_spazi,safe_spazi); print command}' | \
bash
