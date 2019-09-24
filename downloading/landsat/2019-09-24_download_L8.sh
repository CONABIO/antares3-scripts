# mexico_contorno contorno es una geometría en la DB para consultas más rápidas
# su equivalente en shapefile esta en /LUSTRE/MADMEX/shapefiles/mexico_contorno_simple/mex_simple.shp

antares create_order --region 'mexico_contorno'  --start-date '2014-01-01' --end-date '2015-12-31' --max-cloud-cover 30 --landsat 8 --no-order
