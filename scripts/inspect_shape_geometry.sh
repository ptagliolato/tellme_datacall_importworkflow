#!/bin/bash
# outputs 3 tab separated columns: filename (with relative path), layername, ogrinfo-detected-geometryType, epsg (eventually with confidence) by gdalsrsinfo

#tree -if --noreport | grep shp$ | awk '{print "ogrinfo " $0}' | bash | awk '/INFO/{gsub(/INFO: Open of `/,"",$0); gsub(/''/,"",$0); printf("%s\t", $0)} /1:/{gsub(/1:/,"",$0);gsub(/\(/,"\t",$0);gsub(/\)/,"",$0);print $0}'
#for i in $(tree -if --noreport | grep shp$); do ogrinfo -q $i | awk -F="\: | \(|\)" -v fpath="$i" '{gsub("1: ","",$1); output=sprintf("%s\t%s\t%s", fpath, $1, $2);print output}'; done;

for i in $(tree -if --noreport | grep shp$); do ogrinfo -q $i | awk -F="\: | \(|\)" -v fpath="$i" -v epsg="$(gdalsrsinfo -o epsg -e $i)" '{gsub("1: ","",$1); output=sprintf("%s\t%s\t%s\t%s", fpath, $1, $2, epsg);print output}'; done;
