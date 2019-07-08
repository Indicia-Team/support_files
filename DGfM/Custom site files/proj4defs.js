Proj4js.defs["EPSG:2169"] = "+proj=tmerc +lat_0=49.83333333333334 +lon_0=6.166666666666667 +k=1 +x_0=80000 +y_0=100000 +ellps=intl +towgs84=-193,13.7,-39.3,-0.41,-2.933,2.688,0.43 +units=m +no_defs";
Proj4js.defs["EPSG:4314"] = "+proj=longlat +ellps=bessel +datum=potsdam +no_defs";
Proj4js.defs["EPSG:27700"] = "+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs";
Proj4js.defs["EPSG:29901"] = "+proj=tmerc +lat_0=53.5 +lon_0=-8 +k=1 +x_0=200000 +y_0=250000 +ellps=airy +towgs84=482.5,-130.6,564.6,-1.042,-0.214,-0.631,8.15 +units=m +no_defs";
Proj4js.defs["EPSG:31462"] = "+proj=tmerc +lat_0=0 +lon_0=6 +k=1 +x_0=2500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs";
Proj4js.defs["EPSG:31463"] = "+proj=tmerc +lat_0=0 +lon_0=9 +k=1 +x_0=3500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs";
Proj4js.defs["EPSG:31464"] = "+proj=tmerc +lat_0=0 +lon_0=12 +k=1 +x_0=4500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs";
Proj4js.defs["EPSG:3857"] = Proj4js.defs["GOOGLE"];
Proj4js.defs['EPSG:23030'] = "+proj=utm +zone=30 +ellps=intl +units=m +no_defs +towgs84=-87,-98,-121";
Proj4js.defs["EPSG:31466"] = "+proj=tmerc +lat_0=0 +lon_0=6 +k=1 +x_0=2500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs";
Proj4js.defs["EPSG:31467"] = "+proj=tmerc +lat_0=0 +lon_0=9 +k=1 +x_0=3500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs";
Proj4js.defs["EPSG:31468"] = "+proj=tmerc +lat_0=0 +lon_0=12 +k=1 +x_0=4500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs";
// For DGfM move central meridian from 15 to 14 - non-standard, also False_Easting: 33480000,0 (usually 33500000,0)
// Standard definition commented out for reference
// Proj4js.defs["EPSG:5650"] = "+proj=tmerc +lat_0=0 +lon_0=15 +k=0.9996 +x_0=33500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";
Proj4js.defs["EPSG:5650"] = "+proj=tmerc +lat_0=0 +lon_0=14 +k=0.9996 +x_0=33480000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";