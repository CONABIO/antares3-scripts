
# Ingestion
1)Ingestion of S2 20m product

#use for example: 6gb for scheduler, 7gb per worker, 50 instances: m4.xlarge, 93 dask-workers

antares prepare_metadata --path test_jalisco_2018_sentinel2 --bucket conabio-s3-oregon --dataset_name s2_l2a_20m --outfile /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/<some_name_20m.yaml> -sc /shared_volume/scheduler.json 

#count number of datasets that will be ingested:

grep id: /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/<some_name.yaml>|wc -l

datacube -v product add ~/.config/madmex/indexing/s2_l2a_20m_granule.yaml

datacube -v dataset add /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/<some_name_20m.yaml>

#before execution of next line check ip of scheduler doing a:

cat /shared_volume/scheduler.json

#also make sure that file ~/.config/madmex/ingestion/s2_l2a_20m_s3_mexico.yaml has in entry 'bucket' the name: test-read-write-jalisco-s2-2018-2

datacube -v ingest --queue-size 10000 -c ~/.config/madmex/ingestion/s2_l2a_20m_mexico.yaml --executor distributed <ip_of_scheduler>:8786

2)Ingestion of 10m product

#use for example: 6gb for scheduler, 7gb per worker, 50 instances: m4.xlarge, 93 dask-workers

antares prepare_metadata --path test_jalisco_2018_sentinel2 --bucket conabio-s3-oregon --dataset_name s2_l2a_10m_scl --outfile /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/<some_name_10m.yaml> -sc /shared_volume/scheduler.json 

#count number of datasets that will be ingested:

grep id: /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/<some_name_10m.yaml>|wc -l

datacube -v product add ~/.config/madmex/indexing/s2_l2a_10m_scl_granule.yaml

datacube -v dataset add /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/metadata_from_s3_to_s3_10m.yaml

#before execution of next line check ip of scheduler doing a:

cat /shared_volume/scheduler.json

#also make sure that file ~/.config/madmex/ingestion/s2_l2a_10m_scl_s3_mexico.yaml has in entry 'bucket' the name: test-read-write-jalisco-s2-2018-2

datacube -v ingest --queue-size 10000 -c ~/.config/madmex/ingestion/s2_l2a_10m_scl_s3_mexico.yaml --executor distributed <ip_of_scheduler>:8786

3)Ingestion of srtm product

antares prepare_metadata --path dem/srtm_90 --bucket conabio-s3-oregon --dataset_name srtm_cgiar --outfile /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/metadata_srtm_bucket.yaml -sc /shared_volume/scheduler.json

datacube -v product add ~/.config/madmex/indexing/srtm_cgiar.yaml

datacube -v dataset add /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/metadata_srtm_bucket.yaml

#before execution of next line check ip of scheduler doing a:

cat /shared_volume/scheduler.json

#also make sure that file ~/.config/madmex/ingestion/srtm_cgiar_mexico.yaml has in entry 'bucket' the name: test-read-write-jalisco-s2-2018-2

datacube -v ingest -c ~/.config/madmex/ingestion/srtm_cgiar_mexico.yaml --executor distributed <ip_of_scheduler>:8786 


4) Ingestion of S1 data

### use for example: 6gb for scheduler, 7gb per worker, 1 instance: m4.xlarge, 1 dask-workers
antares prepare_metadata --path S1MEX_preprocessed --bucket conabio-s3-oregon --dataset_name s1_grd_vh_vv --outfile /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/metadata_s1_<some_name>_10m.yaml -sc /shared_volume/scheduler.json 

### count number of datasets that will be ingested:
grep id: /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/metadata_s1_<some_name>_10m.yaml|wc -l

datacube -v product add ~/.config/madmex/indexing/sentinel_1_esa_scenes.yaml

datacube -v dataset add /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/metadata_s1_<some_name>_10m.yaml

### before execution of next line check ip of scheduler doing a:
cat /shared_volume/scheduler.json

### also make sure that file ~/.config/madmex/ingestion/s1_snappy_vh_vv_mexico.yaml has in entry 'bucket' for example the name: test-read-write-jalisco-s2-2018-2
#use for example: 6gb for scheduler, 7gb per worker, 50 instances: m4.xlarge, 93 dask-workers
datacube -v ingest --queue-size 2000 -c ~/.config/madmex/ingestion/s1_snappy_vh_vv_mexico.yaml --executor distributed <scheduler_ip>:8786

5) Apply recipe of 20m product
#Apply

5a) One possibility is use next line if s2 20m data was resampled to 10m when was ingested
### 50 instances r4.2xlarge, 50 workers 58GB, scheduler 2GB
antares apply_recipe -recipe s1_2_10m_001 -b 2018-01-01 -e 2018-12-31 -region Jalisco --name s1_<some_name>_s3_to_s3_recipe_2018 -sc /shared_volume/scheduler.json

5b) If s2 20m data wasn't resampled to 10m when was ingested then use:

#first run: 30 dask worker each 115 gb in 30 instances r4.4xlarge, and scheduler 3 gb 
#second run: scheduler of 6gb and 1 dask worker of 230 gb in 1 r4.8xlarge instance
antares apply_recipe -recipe s1_2_20m_resampled_10m_001 -b 2018-01-01 -e 2018-12-31 -region Jalisco --name s1_2_20m_resampled_10m_001_Jalisco_from_s3_to_s3_recipe_2018 --resolution -10 10 --tilesize 50020 50020 --origin 2426720 977160 --proj4 '+proj=lcc +lat_1=17.5 +lat_2=29.5 +lat_0=12 +lon_0=-102 +x_0=2500000 +y_0=0 +a=6378137 +b=6378136.027241431 +units=m +no_defs' -sc /shared_volume/scheduler.json



6) Apply recipe of 10m product

#first run: scheduler of 1gb and 119gb for dask-workers, 20 dask-workers in 20 r4.4xlarge instances
#second run: scheduler of 3gb and 235gb for 1 dask-worker in 1 r4.8xlarge instance

antares apply_recipe -recipe s2_10m_scl_ndvi_mean_001 -b 2018-01-01 -e 2018-12-31 -region Jalisco --name s2_10m_scl_Jalisco_from_s3_to_s3_2_recipe_2018 -sc /shared_volume/scheduler.json


7) Segmentation to result of recipe of 10m product

#2gb scheduler, 13gb workers, r4.xlarge, 20 nodes, 35 dask-workers (could be 40 dask-workers)

#before next command check how much free storage DB has

antares segment --algorithm bis -n s2_10m_Jalisco_seg_from_s3_to_s3_2_2018 -p s2_10m_scl_Jalisco_from_s3_to_s3_2_recipe_2018 -r Jalisco -b ndvi_mean --datasource sentinel_2 --year 2018 -extra t=40 s=0.5 c=0.7 -sc /shared_volume/scheduler.json

#after segment check how much free storage DB has

8) Model fit to result of recipe of 20m product

#18gb scheduler, 6gb workers, r4.xlarge, 20 nodes, 35 dask-workers (could be 40 dask-workers)
antares model_fit -model rf -p s1_2_20m_resampled_10m_001_Jalisco_from_s3_to_s3_recipe_2018 -t mexbits_31 --region Jalisco --sample 1 --remove-outliers --name rf_s1_2_20m_resampled_10m_001_jalisco_from_s3_to_s3_2018 -extra n_estimators=60 -sc /shared_volume/scheduler.json



9)Predict of result of segmentation of 10m product

#2gb scheduler, 14gb workers, r4.xlarge, 20 nodes, 35 dask-workers (could be 40 dask-workers)
antares model_predict_object -p s1_2_20m_resampled_10m_001_Jalisco_from_s3_to_s3_recipe_2018 -m rf_s1_2_20m_resampled_10m_001_jalisco_from_s3_to_s3_2018 -s s2_10m_Jalisco_seg_from_s3_to_s3_2_2018 -r Jalisco --name land_cover_rf_s1_2_20m_resampled_10m_001_jalisco_from_s3_to_s3_2018 -sc /shared_volume/scheduler.json

10)Convert to raster

antares db_to_raster -n land_cover_rf_s1_2_20m_resampled_10m_001_jalisco_from_s3_to_s3_2018 -region Jalisco -f land_cover_rf_s1_2_20m_resampled_10m_001_jalisco_from_s3_to_s3_2018.tif --resolution 10 -p '+proj=lcc +lat_1=17.5 +lat_2=29.5 +lat_0=12 +lon_0=-102 +x_0=2500000 +y_0=0 +a=6378137 +b=6378136.027241431 +units=m +no_defs'

11) Validation (only if validation set and training set have same scheme of classification) 

#not sure how much ram... possibly 29gb in a scheduler of a r4.xlarge instance

antares validate -c land_cover_rf_s1_2_20m_resampled_10m_001_jalisco_from_s3_to_s3_2018 -val bits_interpret -r Jalisco --comment 'validation for Jalisco s2 10m 2018 using gridspec functionality of datacube, bits_interpret as validation data and reading from s3 input images' --log


