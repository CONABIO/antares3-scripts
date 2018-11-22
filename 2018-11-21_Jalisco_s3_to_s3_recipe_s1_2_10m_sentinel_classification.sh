
# Ingestion

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

# Apply

### 50 instances r4.2xlarge, 50 workers 58GB, scheduler 2GB
antares apply_recipe -recipe s1_2_10m_001 -b 2018-01-01 -e 2018-12-31 -region Jalisco --name s1_<some_name>_s3_to_s3_recipe_2018 -sc /shared_volume/scheduler.json

# Model fit

TODO

# Segmentation to result of recipe s1_<some_name>_s3_to_s3_recipe_2018

TODO

# Predict

TODO

# Convert to raster

TODO

