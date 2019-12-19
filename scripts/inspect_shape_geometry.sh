#!/bin/bash

tree -if --noreport | grep shp$ | awk '{print "ogrinfo " $0}' | bash | awk '/INFO/{gsub(/INFO: Open of `/,"",$0); gsub(/''/,"",$0); printf("%s\t", $0)} /1:/{gsub(/1:/,"",$0);gsub(/\(/,"\t",$0);gsub(/\)/,"",$0);print $0}'