OAXACA TEST, LANDSAT 7 2004+2005


######
antares prepare_metadata --path linea_base/L7 --bucket conabio-s3-oregon --dataset_name landsat_espa --outfile metadata_oax_TEST.yaml --pattern ".*LE070(22048|22049|23048|23049|24047|24048|24049|25047|25048|25049)(2004|2005).*" -sc /shared_volume/scheduler.json


######
datacube -v product add ~/.config/madmex/indexing/ls7_espa_scenes.yaml


######
datacube -v dataset add /shared_volume/metadata_landsat7_oax.yaml


######
datacube -v ingest --dry-run -c ~/.config/madmex/ingestion/ls7_espa_mexico.yaml --executor distributed 100.96.2.6:8786
datacube -v ingest --queue-size 1000 -c ~/.config/madmex/ingestion/ls7_espa_mexico.yaml --executor distributed 100.96.2.6:8786


######
antares ingest_training /LUSTRE/MADMEX/tasks/2019_tasks/test_oaxaca_L7/oaxaca_training_test.shp --scheme madmex_31 --year 2015 --name oax_31 --field class


######
2 instances r4.2xlarge, 2 workers 58GB, scheduler 2GB
antares apply_recipe -recipe landsat_madmex_002 -b 2004-01-01 -e 2005-12-31 -region Oaxaca --name l7_oax_recipe_0405 -sc /shared_volume/scheduler.json


######
antares segment --algorithm bis -n oax_seg_0405 -p l7_oax_recipe_0405 -r Oaxaca -b ndvi_mean --datasource landsat --year 2005 -extra t=30 s=0.5 c=0.7 -sc /shared_volume/scheduler.json


######
antares model_fit -model rf -p l7_oax_recipe_0405 -t oax_31 --region Oaxaca -sp mean --name rf_l7_oax_0405 --sample 1 --remove-outliers -extra n_estimators=60 -sc /shared_volume/scheduler.json


######
antares model_predict_object -p l7_oax_recipe_0405 -m rf_l7_oax_0405 -s oax_seg_0405 -r Oaxaca --name land_cover_rf_l7_oax_0405 -sc /shared_volume/scheduler.json


######
antares db_to_raster -n land_cover_rf_l7_oax_0405 -region Oaxaca -f land_cover_rf_l7_oax_0405.tif --resolution 30 -sc /shared_volume/scheduler.json
