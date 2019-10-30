# El archivo geojson son es un contorno simple de México que abarca todas sus islas, se localiza en /LUSTRE/MADMEX/shapefiles/mexico_geojson_simple/mex_full.geojson
# estos comandos descargan escenas Sentinel-2 2018 desde 2018-09-30 hasta 2018-12-31

#next line to count number of scenes and size
sentinelsat -u conabio_1 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20181001 -e 20181231 --cloud 25 --footprints --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
6314 scenes found with a total size of 3242.47 GB

# Ruta de descarga: /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
#execute next lines in: /LUSTRE/MADMEX/shapefiles/mexico_geojson_simple

#nodo5:
#first batch
#downloaded 625 scenes
sentinelsat -u conabio_1 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20181001 -e 20181008 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
#downloaded 639 scenes
sentinelsat -u conabio_1 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20181009 -e 20181017 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
#downloaded 638 scenes
sentinelsat -u conabio_1 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/apihub --producttype S2MSI1C -s 20181018 -e 20181026 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
#downloaded 609 scenes
sentinelsat -u conabio_1 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/apihub --producttype S2MSI1C -s 20181027 -e 20181103 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/

#second batch
#downloaded 684 scenes
sentinelsat -u conabio_2 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20181104 -e 20181111 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
#downloaded 554 scenes
sentinelsat -u conabio_2 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20181112 -e 20181120 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
#downloaded 464 scenes
sentinelsat -u conabio_3 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/apihub --producttype S2MSI1C -s 20181121 -e 20181129 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
#downloaded 590 scenes
sentinelsat -u conabio_3 -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/apihub --producttype S2MSI1C -s 20181130 -e 20181207 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/


#third batch
#downloaded 505 scenes
sentinelsat -u madmex -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20181208 -e 20181216 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
#downloaded 653 scenes
sentinelsat -u madmex -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/dhus --producttype S2MSI1C -s 20181217 -e 20181225 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/
#downloaded 353 scenes
sentinelsat -u madmex -p madmex... -g mex_full.geojson --sentinel 2 --url https://scihub.copernicus.eu/apihub --producttype S2MSI1C -s 20181226 -e 20181231 --cloud 25 -d --path /LUSTRE/MADMEX/imagenes/sentinel2_escenas/2018/


