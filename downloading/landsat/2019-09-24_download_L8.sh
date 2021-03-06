# mexico_contorno contorno es una geometría en la DB para consultas más rápidas
# su equivalente en shapefile esta en /LUSTRE/MADMEX/shapefiles/mexico_contorno_simple/mex_simple.shp

1. Landsat 8 2014-2015
antares create_order --region 'mex_simple'  --start-date '2014-01-01' --end-date '2015-12-31' --max-cloud-cover 30 --landsat 8 
#order id:  ? , total escenas: 3965
antares download_order --order_ids espa-conabio.madmex@gmail.com-09252019-185334-420
#3965 escenas descargadas en: /LUSTRE/MADMEX/imagenes/landsat/L8/2014_2015

2. Landsat 7 2014-2015
antares create_order --region 'mex_simple'  --start-date '2014-01-01' --end-date '2015-12-31' --max-cloud-cover 10 --landsat 7 
#order id: espa-conabio.madmex@gmail.com-10032019-232110-887 , total escenas: 2447

3. Landsat 8 2017-2018
antares create_order --region 'mex_simple'  --start-date '2017-01-01' --end-date '2018-12-31' --max-cloud-cover 30 --landsat 8
# order id: espa-conabio.madmex@gmail.com-10012019-115837-913 , total escenas: 4843

4. Descarga Landsat 8 2017-2018
Cambiar ruta de TEMP_DIR en `.antares` con: /LUSTRE/MADMEX/imagenes/landsat/L8/2017_2018
Crear ruta /LUSTRE/MADMEX/imagenes/landsat/L8/2017_2018
antares download_order -order_ids espa-conabio.madmex@gmail.com-10012019-115837-913


5. Descarga Landsat 7 2014-2015
Cambiar ruta de TEMP_DIR en `.antares` con: /LUSTRE/MADMEX/imagenes/landsat/L7/2014_2015/
Crear ruta /LUSTRE/MADMEX/imagenes/landsat/L7/2014_2015/
antares download_order -order_ids espa-conabio.madmex@gmail.com-10032019-232110-887
