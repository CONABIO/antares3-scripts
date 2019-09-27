# mexico_contorno contorno es una geometría en la DB para consultas más rápidas
# su equivalente en shapefile esta en /LUSTRE/MADMEX/shapefiles/mexico_contorno_simple/mex_simple.shp

# petición 
antares create_order --region 'mexico_contorno'  --start-date '2014-01-01' --end-date '2015-12-31' --max-cloud-cover 30 --landsat 8 
antares create_order --region 'mexico_contorno'  --start-date '2014-01-01' --end-date '2015-12-31' --max-cloud-cover 10 --landsat 7 

# descarga
antares download_order --order_ids espa-conabio.madmex@gmail.com-09252019-180347-664

# por ejecutar: 
antares download_order --order_ids espa-conabio.madmex@gmail.com-09252019-185334-420
