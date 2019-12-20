<!---[![DOI](https://zenodo.org/badge/187632170.svg)](https://zenodo.org/badge/latestdoi/187632170)--->

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

TELLme Datacall Import Workflow
===============================

## Description 
The discipline defined by the TELLme project identifies urban thematics of interest at the metropolitan level.     
For each thematics, the TELLme metropolitan discipline methodologically defines sets of keywords and related concepts (RC). These keywords and RC are collected by the involved partners and community of experts through the project software devoted to the composition of the TELLme-Glossary (http://www.tellme.polimi.it/tellme_apps/tellme/login) and are made publicly available as Linked Data (http://rdfdata.get-it.it/TELLmeGlossary).  
Thematics definition converges into "Semantic Packages" (SP), i.e. sets of RC, and then to maps. One type of SP is called "Protocol" (thematics appliable to any metropolis). The protocol map is a composition of layers. Each layer is representative of one of the "related-concepts" constituting the protocol. Many of these layers has been identified among globally available geospatial data. Some related concept, instead, must be collected from local sources. TELLme project partners are called to contribute local data in those cases.

## Data call description and settings
Each call is defined by a list of Protocol-related semantic package (SP). (Each protocol can be declined in one or more scale in dependence of the required dimention of the thematics - e.g. "XL" means that data must include a more vast area than the whole metropolis, while "XS" could regard very specific thematics focussing for example on neighborhoods). 
The SP concepts which require local data are then the subject of the data call. 

A data call needs, in its definition:
- the set of triples \<RC, the specification for its expected layer of its semantics, its technical specification (e.g. kind of geometries)\>.
- operationally, the RC are organized in a tree folder structure, where each partner is invited to publish its data (or the reference to an OGC WMS/WFS service already providing it); the semantics and techincal specification of the expected layers are provided in project reports (while the semantics of the concepts themselves are described within the TELLme Glossary).
       
## Expected folder structure and settings files
The scripts can be used with a data folder-structure of the following kind:

    <ROOT-FOLDER>
    ├──	<CITY-1>
	├── <TELLme-PROTOCOL-1>_<TELLme-SCALE>
	│   ├── <TELLme-KEYWORD-A>
	│   ├── <TELLme-KEYWORD-B>
	│   │   └── <RELATED-CONCEPT-X>
	│   │       ├── mapa\ productivo\ norte.shp
	│   │       ├── mapa\ productivo\ norte.dbf
	│   │       ├── mapa\ productivo\ norte.prj
	│   │       ├── ...
	│   │       ├── ...
	│   │       └── mapa\ productivo\ norte.shx
	│   ├── <TELLme-KEYWORD-C>
	│   └── <TELLme-KEYWORD-D>
	│       └── <RELATED-CONCEPT-Y>
	│           ├── degradacion-general.shp
	│           ├── degradacion-general.dbf
	│           ├── degradacion-general.prj
	│           ├── ...
	│           ├── ...
	│           └── degradacion-general.shx
	└── <TELLme-PROTOCOL-2>_<TELLme-SCALE>
	    ├── ...
	    
Where:
- \<CITY-1\> is the name of the city the layer are provided for. E.g. "MILAN" or "GUADALAJARA"
- \<TELLme-PROTOCOL-1\>_\<TELLme-SCALE\> is the composition of the name of the TELLme protocol map name with the scale. E.g. "GREEN_GREY_INFRASTRUCTURE_L"
- \<TELLme-KEYWORD-A\> is the capitalized label of one of the TELLme keywords. E.g. "GREEN_INFRASTRUCTURE"
- \<RELATED-CONCEPT-X\> is the capitalized label of one of the TELLme related concepts to the preceding keyword. E.g. "AGRICOLTURAL_TYPE"

The scripts need for their execution two files containing lookup tables to match folder names with related concepts and with metropolis.
The two files (\*lookupTable.tsv) contain this information.
- The metropolis is a three columns table for: folder-name, metropolis-abbreviation, geographical region of the metropolis.
- The related concept table contains three columns: folder-name, concept numeric id, concept label (the label is the one within the TELLme-HUB, and please note that it could be not synchronized at any moment with the metropolitan glossary).

## Operations of the workflow
- Read a folder structure containing layer files in shp format.
- Preprocess file names in order to correct OS issues (spaces, accented characters).
- Compose a report, via ogrinfo, containing information about actual geometry type of each shapefile.
- Compose statements for importing layers within the TELLme-Hub GET-IT instance.
- Compose post-import statements invoking, via curl program, geoserver API in order to associate each layer with the appropriate style for TELLme cartography.
- The scripts must be copied to the data folder-structure root and executed within it.

# Usage
Once the scripts have been copied into the data-folder structure, in the ROOT folder

	> cd ROOT-FOLDER
	> # clean file names: run 
	> ./clean_file_names.sh
	> # obtain the report of all shape files with the contained geometry (output is printed in terminal): run
	> ./inspect_shape_geometry.sh
	> # obtain import statements to ingest files in TELLme-HUB: run 
	> tree -if --noreport | grep shp | awk -v FQDN="tellmehub.get-it.it" -v user="<geoserveruser>" -v pass="<geoserverpassword>" -v container_absolute_path_prefix="/usr/src/app/tellme_datacall/" -f importLookupArray.awk
	
The parameter to the awk script have the following meaning, and should be adapted to environment.
- 'FQDN' must contain the web domain of the installation of TELLme-HUB instance where data are going to published
- 'user' and 'pass' represent the actual administrative account of the geoserver associated to the TELLme-HUB instance
- 'container_absolute_path_prefix' is the path, within the "django" container of TELLme-HUB instance, where the files will be uploaded (note: the suggested use is to maintain the value "/usr/src/app/tellme\_datacall", and to use the tellme\_datacall in the TELLme-HUB folder on the host where TELLme-HUB is deployed).
	
## Docker image and docker-compose
The docker image contains an environment to successfully run the scripts. It contains gdal-ogr and the tree utility that are prerequisite.
The /usr/src/app folder contains all the scripts. The folder structure with data must be mounted at this same mount point:
this can be achieved using the docker-compose, by specifying the path in the docker host to the data folder within the .env file variable ROOT_DATA_FOLDER.  

## Build docker image
    docker build -t ptagliolato/tellme_datacall_importworkflow:<tag> .
    
## Meta

* Please [provide a new manufacturer information by issues](https://github.com/ptagliolato/tellme_datacall_importworkflow/issues), or email tagliolato.p(at)irea.cnr.it
* License: The collection is being developed by Paolo Tagliolato ([IREA-CNR](http://www.irea.cnr.it)), and it is released under the [GNU General Public License version 3](https://www.gnu.org/licenses/gpl-3.0.html) (GPL‑3).
<!---* Get citation information for RDF-FOAF Manufacturers list

``` bibtex
@misc{alessandro_oggioni_2019_3247546,
  author       = {Alessandro Oggioni},
  title        = {{oggioniale/RDF-FOAF-Manufacturer-list: First 
                   release of RDF-FOAF Manufacturers list}},
  month        = jun,
  year         = 2019,
  doi          = {10.5281/zenodo.3247546},
  url          = {https://doi.org/10.5281/zenodo.3247546}
}
```
--->
