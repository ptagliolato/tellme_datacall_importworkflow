#!/bin/bash
# outputs 3 tab separated columns: filename, layername, ogrinfo-detected-geometryType

#tree -if --noreport | grep shp$ | awk '{print "ogrinfo " $0}' | bash | awk '/INFO/{gsub(/INFO: Open of `/,"",$0); gsub(/''/,"",$0); printf("%s\t", $0)} /1:/{gsub(/1:/,"",$0);gsub(/\(/,"\t",$0);gsub(/\)/,"",$0);print $0}'
tree -if --noreport | grep shp$ | awk '{print "FILE=" $0 "; ogrinfo -q " $0}' | bash | awk -v FILE="$(echo $FILE)" -F=": | \(|\)" '{gsub("1: ","",$1); output=sprintf("%s\t%s\t%s", FILE, $1, $2);print output}'
