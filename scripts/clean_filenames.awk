# check layer filenames: they must not contain spaces. The same applies to the tree.
#
# USAGE: tree -if --noreport | grep " " | awk -f clean_filenames
#
# Hint: to correct filenames with accented characters (<path>, use:
#
#   mv <path> $(echo "<path>" | iconv -f utf8 -t ascii//TRANSLIT)
#
########
# To automate, try to use the following commands:
#
# --------
# 1. -dif option is used to select directory names only (may be necessary to use it multiple times if accented characters are present in several dirs/subdirs of the tree
# --------
# tree -dif --noreport > original_names.txt && tree -dif --noreport | iconv -f utf8 -t ascii//TRANSLIT > translittered_names.txt && diff --unchanged-line-format= --old-line-format= --new-line-format="%L" translittered_names.txt original_names.txt | awk 'BEGIN{} {safe_spazi=$0; gsub(/ /,"\\ ",safe_spazi); command=sprintf("mv %s \"$(echo \"%s\" | iconv -f utf8 -t ascii//TRANSLIT)\"",safe_spazi,safe_spazi); print command}' | bash
#
#---------
# 2. then filenames can be processed.
# --------
# tree -if --noreport > original_names.txt && tree -if --noreport | iconv -f utf8 -t ascii//TRANSLIT > translittered_names.txt && diff --unchanged-line-format= --old-line-format= --new-line-format="%L" translittered_names.txt original_names.txt | awk 'BEGIN{} {safe_spazi=$0; gsub(/ /,"\\ ",safe_spazi); command=sprintf("mv %s \"$(echo \"%s\" | iconv -f utf8 -t ascii//TRANSLIT)\"",safe_spazi,safe_spazi); print command}' | bash
##########
BEGIN{
    print "# if you encounter erroes when piped to bash, that is probably due to changes occured in directory names. Execute more times (max: tree depth time) in order for the process to complete." 
    print "# to correct filenames with accented characters, please execute mv <path> $(echo \"<path>\" | iconv -f utf8 -t ascii//TRANSLIT)"
}
{
    correct_spaces=$0
    path_with_spaces=$0
    gsub(/ /,"_",correct_spaces)
    gsub(/ /,"\\ ",path_with_spaces)
    output=sprintf("mv %s %s",path_with_spaces,correct_spaces)

    print output
}
