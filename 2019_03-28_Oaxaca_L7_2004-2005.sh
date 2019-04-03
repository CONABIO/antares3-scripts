#Usamos db: test_no_gaps para .datacube.conf y test_from_s3_to_s3_2 para .antares

#bucket test-landsat-l7
#6 r4.xlarge instances

# scheduler 4 gb, 16 workers with 5 gb each

antares prepare_metadata --path linea_base/L7_NOGAPS --bucket conabio-s3-oregon --dataset_name landsat_espa --outfile metadata_oax_no_gaps.yaml -sc /shared_volume/scheduler.json

datacube -v product add ~/.config/madmex/indexing/ls7_espa_scenes.yaml

datacube -v dataset add metadata_oax_no_gaps.yaml

# before running ingest add the bucket name to the yaml file
datacube -v ingest --queue-size 2000 -c ~/.config/madmex/ingestion/ls7_espa_mexico.yaml --executor distributed 100.96.24.4:8786

#srtm:

datacube -v product add ~/.config/madmex/indexing/srtm_cgiar.yaml

datacube -v dataset add /shared_volume/metadata_srtm_bucket.yaml

datacube -v ingest -c ~/.config/madmex/ingestion/srtm_cgiar_mexico.yaml --executor distributed 100.96.24.4:8786


# scheduler 4 gb, 12 workers with 10gb each
antares apply_recipe -recipe landsat_madmex_002 -b 2004-01-01 -e 2005-12-31 -region Oaxaca --name l7_oax_50km_no_gaps_recipe_0405 -sc /shared_volume/scheduler.json


Command execution is done in 261.692054271698 seconds.

antares segment --algorithm bis -n oax_seg_50km_no_gaps_0405 -p l7_oax_50km_no_gaps_recipe_0405 -r Oaxaca -b ndvi_mean --datasource landsat7 --year 2005 -extra t=30 s=0.5 c=0.7 -sc /shared_volume/scheduler.json

Command execution is done in 924.7343854904175 seconds.

antares model_fit -model rf -p l7_oax_50km_no_gaps_recipe_0405 -t oax_31 --region Oaxaca -sp mean --name rf_l7_oax_0405_50km_no_gaps --sample 1 --remove-outliers -extra n_estimators=60 -sc /shared_volume/scheduler.json

Command execution is done in 159.22286462783813 seconds.

#scheduler 4gb, 4 gb each dask worker, 17 dask-workers

antares model_predict_object -p l7_oax_50km_no_gaps_recipe_0405 -m rf_l7_oax_0405_50km_no_gaps -s oax_seg_50km_no_gaps_0405 -r Oaxaca --name land_cover_rf_l7_oax_0405_50km_no_gaps -sc /shared_volume/scheduler.json

Command execution is done in 363.85774970054626 seconds.

#scheduler 10gb, 2gb each dask worker

antares db_to_raster -n land_cover_rf_l7_oax_0405_50km_no_gaps -region Oaxaca -f land_cover_rf_l7_oax_0405_50km_no_gaps_new_db_to_raster.tif --resolution 30 -sc /shared_volume/scheduler.json

Command execution is done in 175 seconds.
