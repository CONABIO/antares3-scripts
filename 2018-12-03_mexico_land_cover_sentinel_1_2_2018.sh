#buckets:

#srtm:
datacube-srtm-mexico-s3

#s2 bands 20m resampled to 10m:
datacube-s2-20m-resampled-mexico-s3

#s2 bands 10m:
datacube-s2-10m-mexico-s3

#database: antares_datacube

#ingest:

# Ingestion

1)Ingestion of S2 20m product

#use for example: 6gb for scheduler, 7gb per worker, x instances: m4.xlarge, x dask-workers

antares prepare_metadata --path MEX_S2_preprocessed/2018 --bucket conabio-s3-oregon --dataset_name s2_l2a_20m --outfile /shared_volume/tasks/2018/landcover_2018/<some_name_20m.yaml> -sc /shared_volume/scheduler.json 

#count number of datasets that will be ingested:

grep id: /shared_volume/tasks/2018/landcover_2018/<some_name.yaml>|wc -l

datacube -v product add ~/.config/madmex/indexing/s2_l2a_20m_granule.yaml

datacube -v dataset add /shared_volume/tasks/2018/national_landcover/2018/<some_name_20m.yaml>

#before execution of next line check ip of scheduler doing a:

cat /shared_volume/scheduler.json

#two options:

#1) also make sure that file ~/.config/madmex/ingestion/s2_l2a_20m_mexico.yaml has in entry 'bucket' the name: datacube-s2-20m-mexico-s3
#next line for no resampling to 10m when ingesting:
datacube -v ingest --queue-size 10000 -c ~/.config/madmex/ingestion/s2_l2a_20m_mexico.yaml --executor distributed <ip_of_scheduler>:8786

#2) also make sure that file ~/.config/madmex/ingestion/s2_l2a_20m_s3_mexico.yaml has in entry 'bucket' the name: datacube-s2-20m-resampled-mexico-s3
#next line for resampling to 10m when ingesting:
datacube -v ingest --queue-size 10000 -c ~/.config/madmex/ingestion/s2_l2a_20m_s3_mexico.yaml --executor distributed <ip_of_scheduler>:8786


2)Ingestion of 10m product

#use for example: 6gb for scheduler, 7gb per worker, x instances: m4.xlarge, x dask-workers

antares prepare_metadata --path MEX_S2_preprocessed/2018 --bucket conabio-s3-oregon --dataset_name s2_l2a_10m_scl --outfile /shared_volume/tasks/2018/national_landcover/2018/<some_name_10m.yaml> -sc /shared_volume/scheduler.json 

#count number of datasets that will be ingested:

grep id: /shared_volume/tasks/2018/national_landcover/2018/<some_name_10m.yaml>|wc -l

datacube -v product add ~/.config/madmex/indexing/s2_l2a_10m_scl_granule.yaml

datacube -v dataset add /shared_volume/tasks/2018/national_landcover/2018/<some_name_10m.yaml>

#before execution of next line check ip of scheduler doing a:

cat /shared_volume/scheduler.json

#also make sure that file ~/.config/madmex/ingestion/s2_l2a_10m_scl_s3_mexico.yaml has in entry 'bucket' the name: datacube-s2-10m-mexico-s3

datacube -v ingest --queue-size 10000 -c ~/.config/madmex/ingestion/s2_l2a_10m_scl_s3_mexico.yaml --executor distributed <ip_of_scheduler>:8786

3)Ingestion of srtm product

antares prepare_metadata --path dem/srtm_90 --bucket conabio-s3-oregon --dataset_name srtm_cgiar --outfile /shared_volume/tasks/2018/national_landcover/2018/metadata_srtm_bucket.yaml -sc /shared_volume/scheduler.json

datacube -v product add ~/.config/madmex/indexing/srtm_cgiar.yaml

datacube -v dataset add /shared_volume/tasks/2018/national_landcover/2018/metadata_srtm_bucket.yaml

#before execution of next line check ip of scheduler doing a:

cat /shared_volume/scheduler.json

#also make sure that file ~/.config/madmex/ingestion/srtm_cgiar_mexico.yaml has in entry 'bucket' the name: datacube-srtm-mexico-s3

datacube -v ingest -c ~/.config/madmex/ingestion/srtm_cgiar_mexico.yaml --executor distributed <ip_of_scheduler>:8786 


4) Ingestion of S1 data

### use for example: 6gb for scheduler, 7gb per worker, 1 instance: m4.xlarge, 1 dask-workers

antares prepare_metadata --path S1MEX_preprocessed --bucket conabio-s3-oregon --dataset_name s1_grd_vh_vv --outfile /shared_volume/tasks/2018/national_landcover/2018/metadata_s1_<some_name>_10m.yaml -sc /shared_volume/scheduler.json 

### count number of datasets that will be ingested:
grep id: /shared_volume/tasks/2018/national_landcover/2018/metadata_s1_<some_name>_10m.yaml|wc -l

datacube -v product add ~/.config/madmex/indexing/sentinel_1_esa_scenes.yaml

datacube -v dataset add /shared_volume/tasks/2018/national_landcover/2018/metadata_s1_<some_name>_10m.yaml

### before execution of next line check ip of scheduler doing a:
cat /shared_volume/scheduler.json

### also make sure that file ~/.config/madmex/ingestion/s1_snappy_vh_vv_mexico.yaml has in entry 'bucket' for example the name: "datacube-s1-mexico-s3",
#use for example: 6gb for scheduler, 7gb per worker, 50 instances: m4.xlarge, 93 dask-workers
datacube -v ingest --queue-size 2000 -c ~/.config/madmex/ingestion/s1_snappy_vh_vv_mexico.yaml --executor distributed <scheduler_ip>:8786


