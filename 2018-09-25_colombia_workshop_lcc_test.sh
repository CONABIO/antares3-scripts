antares create_order --shape 'workshop' --start-date '2015-01-01' --end-date '2016-02-26' --landsat 8 --max-cloud-cover 80

antares download_order

ls . |grep LC08.* > lista.txt

#edit lista.txt

for file in $(cat lista.txt);do newdir=$(basename -s .tar.gz $file);sudo mkdir $newdir; sudo tar xvf $file -C $newdir;aws s3 cp $newdir s3://humboldt-data/landsat8/$newdir --recursive; sudo rm -r $file $newdir;done


#4gb per worker for ingest:

datacube -v system init --no-init-users

antares prepare_metadata --path landsat8 --bucket humboldt-data --dataset_name landsat_espa --outfile /shared_volume/metadata_landsat_bucket.yaml --multi 4

#grep id: /shared_volume/metadata_landsat_bucket.yaml|wc -l
#345 imágenes

datacube -v product add ~/.config/madmex/indexing/ls8_espa_scenes.yaml

datacube -v dataset add /shared_volume/metadata_landsat_bucket.yaml

datacube -v ingest -c ~/.config/madmex/ingestion/ls8_espa_colombia.yaml --executor distributed 100.96.7.14:8786

#3200 successful, 0 failed

# INgest SRTM DEM

antares prepare_metadata --path srtm --bucket humboldt-data --dataset_name srtm_cgiar --outfile /shared_volume/metadata_srtm_bucket.yaml --multi 4

datacube -v product add ~/.config/madmex/indexing/srtm_cgiar.yaml

#Added "srtm_cgiar_mosaic"
datacube -v dataset add /shared_volume/metadata_srtm_bucket.yaml

datacube -v ingest -c ~/.config/madmex/ingestion/srtm_cgiar_colombia.yaml --executor distributed 100.96.9.15:8786

#336 successful, 0 failed

#Ingest training data

antares ingest_training --shape poligonos_entrenamiento_2010.shp --interpret CODIGO --predict CODIGO --scheme humboldt --year 2010 --dataset colombia

#apply recipe (5gb scheduler, 6gb workers, r4.xlarge, 3 nodes, 8 dask-workers)

antares apply_recipe -recipe landsat_colombia_001 -b 2015-01-01 -e 2015-12-31 --region workshop --name landsat_colombia_001_recipe_2015 -sc /shared_volume/scheduler.json

Processing done, 36 tiles written to disk

#segmentation (5gb scheduler, 6gb workers, r4.xlarge, 3 nodes, 8 dask-workers)

antares segment --algorithm bis -n landsat_colombia_seg_2015 -p landsat_colombia_001_recipe_2015 -r workshop -b ndvi_mean ndmi_mean --datasource landsat --year 2015 -extra t=30 s=0.5 c=0.7 -sc /shared_volume/scheduler.json


# Train a model (11gb scheduler, 6gb workers, r4.xlarge, 4 nodes, 11 dask-workers)


antares model_fit -model lgb -p landsat_colombia_001_recipe_2015 -t train_colombia_workshop --region workshop -sp mean --name lgb_landsat_colombia_workshop_2015 --sample 0.3 --remove-outliers -extra n_estimators=150 -sc /shared_volume/scheduler.json

# Model predict (11gb scheduler, 9gb workers, r4.xlarge, 4 nodes, 11 dask-workers)

antares model_predict_object -p landsat_colombia_001_recipe_2015 -m lgb_landsat_colombia_workshop_2015 -s landsat_colombia_seg_2015 -r workshop --name land_cover_colombia_workshop_landsat_2015 -sc /shared_volume/scheduler.json

#result to raster 

antares db_to_raster -n land_cover_colombia_workshop_landsat_2015 -region workshop -f land_cover_colombia_workshop_landsat_2015.tif --resolution .000269 -p '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'

#result cp to s3

aws s3 cp /shared_volume/land_cover/land_cover_colombia_workshop_landsat_2015 s3://humbold-data/land_cover_workshop

