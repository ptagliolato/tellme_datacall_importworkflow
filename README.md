## Description
Read a folder structure containing layer files in shp format.

Preprocess file names in order to correct OS issues (spaces, accented characters).

Compose a report, via ogrinfo, containing information about actual geometry type of each shapefile.

Compose statements for importing layers within the TELLme-Hub GET-IT instance.

Compose post-import statements invoking, via curl program, geoserver API in order to associate each layer with the appropriate style for TELLme cartography.

The scripts must be copied to the data folder-structure root and executed within it.

## Data call description and settings
The discipline defined by the TELLme project identifies urban thematics of interest at the metropolitan level.     
For each thematics, the TELLme metropolitan discipline methodologically defines sets of keywords and related concepts (RC). These keywords and RC are defined by the involved partners and community of experts: they are collected through the project software devoted to the composition of the TELLme-Glossary (http://www.tellme.polimi.it/tellme_apps/tellme/login) and are made publicly available as Linked Data (http://rdfdata.get-it.it/TELLmeGlossary).  
Thematics definition converges into "Semantic Packages" (SP), i.e. sets of RC, and then to maps. One type of SP is called "Protocol" (thematics appliable to any metropolis). The protocol map is a composition of layers. Each layer is representative of one of the "related-concepts" constituting the protocol. Many of these layers has been identified among globally available geospatial data. Some related concept, instead, must be collected from local sources. TELLme project partners are called to contribute local data in those cases.

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


## Docker image and docker-compose
The docker image contains an environment to successfully run the scripts. It contains gdal-ogr and the tree utility that are prerequisite.
The /usr/src/app folder contains all the scripts. The folder structure with data must be mounted at this same mount point:
this can be achieved using the docker-compose, by specifying the path in the docker host to the data folder within the .env file variable ROOT_DATA_FOLDER.  

## Build docker image
    docker build -t ptagliolato/tellme_datacall_importworkflow:<tag> .
