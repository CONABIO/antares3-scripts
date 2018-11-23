
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

5) Apply recipe
#Apply

5a) One possibility is use next line if s2 20m data was resampled to 10m when was ingested
### 50 instances r4.2xlarge, 50 workers 58GB, scheduler 2GB
antares apply_recipe -recipe s1_2_10m_001 -b 2018-01-01 -e 2018-12-31 -region Jalisco --name s1_<some_name>_s3_to_s3_recipe_2018 -sc /shared_volume/scheduler.json

5b) If s2 20m data wasn't resampled to 10m when was ingested then use:

# Model fit

TODO

# Segmentation to result of recipe s1_<some_name>_s3_to_s3_recipe_2018

TODO

# Predict

TODO

# Convert to raster

TODO

