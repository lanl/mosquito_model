Readme for hydropop files.

Note that these files and structures are subject to change. Contact jschwenk@lanl.gov if you want to see
different formats or more data. Note also that the Hydropop forumlation will also certainly change,
so these are not final. However, they represent the file types and information that a downstream user
can expect. So the boundaries themselves might change, but the information and file structures should not
unless someone requests something different.

README laid out as:
File
Description
Detailied description

roi.shp (and associated files .cpg, .dbf, .prj, .shx)
A polygon (EPSG:4326) representing the study area considered for these files. 
Any polygon can be provided; if you want a different study area, send me a message.

hpus.tif
A geotiff (EPSG:4326) of Hydropop Units. Pixel values represent the unit to which the HPU belongs.
[]

hpu_classes.tif
A geotiff (EPSG:4326) of Hydropop classes. Pixel values represent the class to which the HPU belongs.
A HP class is the "cluster" to which the pixel belongs. There are as many classes as groups specified 
to the clustering algorithm (kmeans in this case). Classes, in general, have similar human
populations and hydrotopo habitat potential values. HPUs are derived from classes by considering
spatial connectivity.

hpus.shp (and associated files .cpg, .dbf, .prj, .shx)
A shapefile (EPSG:4326) containing the HPUs as polygons (or MultiPolygons) and some attributes.
Attributes include:
	hpu_id : unique HPU identifier
	hthi_mean : the mean value of the hydrotopo habitat index within that HPU
	pop_mean : the mean value of the human population within the HPU (need to check units here)
	area_sum : the area of the HPU in square km
	hpu_class : the class to which the HPU belongs
	centroid_x : the longitude of the centroid of the HPU
	centroid_y : the latitude of the centroid of the HPU

areagrid.tif
A geotiff (EPSG:4326) for which pixel values represent the area of the pixel in square km.
This is used for computing actual HPU areas, as working in unprojected coordinate systems (4326) 
require a bit of extra work to estimate pixel areas in meaningful units (km instead of degrees).

adjacency.csv
An adjacency matrix that provides connectivity information among HPUs.
Use in conjunction with adjacency_map.csv.
Note that we will want to use sparse representations of adjacency ultimately; I am not sure what
the best strategy is here. 

adjacency_map.csv
A mapper between the row/column in the adjacency matrix and the HPU id.
There are two columns:
	'row_in_matrix' : refers to the (0-indexed) row in adjacency.csv
	'hpu_id' : refers to the HPU id as provided by hpus.shp
Use this information to look up all a HPUs neighbors; for example, if 'hpu_id' == 2, we see that the
'row_in_matrix' value is 0. So all the non-zero entries in the adjacency matrx in the first row (or
column) can be found, then we need to use the mapper again to identify which 'hpu_id's those rows (or
columns) correspond to, resulting in the 'hpu_id's that are connected to 'hpu_id'==2.


