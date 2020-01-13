# ------- INSTRUCTIONS:
#
# use within the folder containing city folders, relatedConceptLookupTable.tsv, metropolisLookupTable.tsv.
# The script is designed to be called this way:
#
# tree -if --noreport | grep shp | awk -v FQDN="tellmehub.get-it.it" -v user="geoserveruser" -v pass="geoserverpassword" -v container_absolute_path_prefix="/usr/src/app/tellme_datacall/" -f importLookupArray.awk
#
# the script outputs the command lines to invoke geonode importlayers script 
# 
# the output can be piped to bash in order for the sentences to be executed (each line starts with
# "docker-compose exec django" in order to be executed in the get-it django container from the host)
#
# Side effect: the file "importOutputLog.txt" is written in the execution folder with some details.
# --------
#
# TODO: integrate layer styling through geoserver rest api. The following should set the default style for a layer. (note: it could be one of different strategies).
#       Investigate which layer name should we use (is it the "name" set in the following importlayers command option or other? something like "geonode:<name>"?
#
# curl -v -u username:password -X PUT -H "Content-type: text/xml" -d "<layer><defaultStyle><name>islandarea</name> </defaultStyle><enabled>true</enabled></layer>" http://localhost:8080/geoserver/rest/layers/geonode:islandarea
#
#
BEGIN{
  ROOTDIRLEVEL=1; # depth of ROOTDIR with respect to current directory, where the script is invoked
  getit_FQDN=FQDN; #ex."tellmehub.get-it.it"
  geoserver_username=user;
  geoserver_password=pass;
  pathprefix=container_absolute_path_prefix;
  out_postproduction="tellme_datacall/output_postproduction_curl_statement.txt"
  out_log="tellme_datacall/output_importStatementsLog.txt"

  while(getline < "relatedConceptLookupTable.tsv"){
    split($0,ft,"\t")
    conceptname=ft[1]; #the concept name used in the folder structure of the data call.
    conceptslug=sprintf("concept_%d",ft[2]); #the concept slug is of the form concept_nn where nn is the numeric ID of the concept.
#current concept label within TELLme-Hub (each RC is imported as a geonode HierarchicalKeyword with a static slug, but labels may vary according to further upgrades of the TELLme Glossary: the HK representation of the Glossary within TELLme-Hub may not be synchronized with it at the moment of importing data.
    currentname=ft[3]; # current concept label in TELLme-Hub (see previous line comment)

    # dictionaries used later to convert folder-names to slugs, current TELLme-Hub labels, concept numeric id
    label2conceptslug[conceptname]=conceptslug; 
    conceptslug2currentname[conceptslug]=currentname;
    conceptslug2conceptid[conceptslug]=ft[2];
  }
  close("relatedConceptLookupTable.tsv");
  while(getline < "metropolisLookupTable.tsv"){
    split($0,ft,"\t");
    cityname=ft[1];
    cityabbrev=ft[2];
    city2cityabbrev[cityname]=cityabbrev;    
    city2region[cityname]=ft[3];
  }
  close("metropolisLookupTable.tsv");
  FS="/";
}
/ /{
  warning=sprintf("# --- WARNING: file %s \n#      filename contains spaces, please use clean_filename.awk script to correct the issue: ", $0)
  print warning;
  print "# tree -if --noreport | grep \" \" | awk -f clean_filenames"
  next;
}
{
  relative_path_and_filename=$0;
  container_absolute_path_and_filename=sprintf("%s%s",container_absolute_path_prefix,relative_path_and_filename)
  sub(/\.\//,"",container_absolute_path_and_filename);

  city=$(ROOTDIRLEVEL+2);
  user=city; #NOTE: currently each city team has a user whose id is the city name capitalized (written exactly as the first column of "metropolisLookupTable.tsv" file)
  protocol=$(ROOTDIRLEVEL+3);
  keyword=$(ROOTDIRLEVEL+4);
  relatedConcept=$(ROOTDIRLEVEL+5);
  
  protocolid=1; #TODO: change this for upcoming protocols in the future. Use a lookup table like the ones for cities and concepts
  
  l=split(protocol,protocolsplit,"_");
  scale=protocolsplit[l];

  conceptslug=label2conceptslug[relatedConcept];
  currentconceptname=conceptslug2currentname[conceptslug]; 
  cityabbrev=city2cityabbrev[city];
  cityprefix=sprintf("%s_", cityabbrev);
  region=city2region[city];
  conceptid=conceptslug2conceptid[conceptslug];
  
  # if lookup do not succeed, it is not an accepted city or concept: skip the record
  if(cityabbrev=="" || currentconceptname==""){
    print "# WARNING: lookup issue for the record " $0 " - I skip it"; 
    print "# it is not an accepted city or concept";
    next;
  }


  row=sprintf("city: %s\tprotocol: %s\tconcept: %s\tslug: %s", city, protocol, relatedConcept, conceptslug);
  print row > "output_importLog.txt";
  split($(ROOTDIRLEVEL+6),filename,".");
  layertitle=filename[1];
  gsub(/\\ /,"_",layertitle);
  if(index(layertitle,cityprefix)==0){
    layertitle=sprintf("%s%s", cityprefix, layertitle)
  }


  output=sprintf("docker-compose exec django python manage.py importlayers --keywords=%s --user=%s --title=%s --regions=%s --charset=UTF-8 %s", currentconceptname, user, layertitle, region, container_absolute_path_and_filename);
  print output;

  postproduction=sprintf("# add here commands to associate styles to the layer. Layer: %s\tConcept_id:%s\tProtocol (i.e. protocol and scale, to be looked up): %s", layertitle, conceptslug, protocol);
  print postproduction > out_log;#"output_importLog.txt";

  stylename=sprintf("c_%s-p_%s-s_%s",conceptid,protocolid,scale);
  geoserver_layername=sprintf("geonode:%s",layertitle);
  geoserverAPI_CURL_command=sprintf("curl -v -u %s:%s -X PUT -H \"Content-type: text/xml\" -d \"<layer><defaultStyle><name>%s</name> </defaultStyle><enabled>true</enabled></layer>\" http://%s/geoserver/rest/layers/%s", geoserver_username, geoserver_password, stylename, getit_FQDN, geoserver_layername);

  print geoserverAPI_CURL_command > out_postproduction;#"output_postproduction_curl_statement.txt";

}

END{
  
  close(out_postproduction)
  close(out_log)
}

