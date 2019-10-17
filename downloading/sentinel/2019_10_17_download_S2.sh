# El archivo geojson son es un contorno simple de México que abarca todas sus islas, se localiza en /LUSTRE/MADMEX/shapefiles/mexico_geojson_simple/mex_full.geojson
# estos comandos descargan escenas Sentinel-2 2018 desde 2018-09-30 hasta 2018-12-31
# Total escenas: 
# tamaño de descarga: 
# Ruta de descarga: /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/

# 1er ronda
sentinelsat -u conabio_1 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20190101 -e 20190119 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
sentinelsat -u conabio_1 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20190119 -e 20190202 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
sentinelsat -u conabio_2 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20190202 -e 20190218 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
sentinelsat -u conabio_2 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20190218 -e 20190303 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
sentinelsat -u conabio_3 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20190303 -e 20190320 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
sentinelsat -u conabio_3 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20190320 -e 20190403 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
sentinelsat -u madmex -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20190403 -e 20190415 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
sentinelsat -u madmex -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20190415 -e 20190429 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
sentinelsat -u madmex -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/apihub --producttype S2MSI1C -s 20190429 -e 20190513 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
sentinelsat -u madmex -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/apihub --producttype S2MSI1C -s 20190513 -e 20190526 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/

