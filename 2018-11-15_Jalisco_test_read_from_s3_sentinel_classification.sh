#test Jalisco 2018 on k8s cluster, data is in s3://conabio-s3-oregon/test_jalisco_2018_sentinel2

1)create a bucket in S3 to hold ingestion process results of datacube, for example test-read-write-jalisco-s2-2018-2

#modify IAM service to read and write to this bucket

2) Start k8s-cluster according to requirements of Ingestion process (first step of land cover steps)

3) In scheduler create a test DB, for example: test_from_s3_to_s3_2

createdb -h <host of DB> -U <user of DB> <name of test DB>

#will prompt for password

4)In scheduler modify entry db_database in ~/.datacube.conf according to name of DB that was created (test_from_s3_to_s3_2)

5)Init datacube with:

datacube -v system init --no-init-users

Land cover steps:

1)Ingestion of 20m product

#use for example: 6gb for scheduler, 7gb per worker, 50 instances: m4.xlarge, 93 dask-workers

antares prepare_metadata --path test_jalisco_2018_sentinel2 --bucket conabio-s3-oregon --dataset_name s2_l2a_20m --outfile /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/<some_name_20m.yaml> -sc /shared_volume/scheduler.json 

#count number of datasets that will be ingested:

grep id: /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/<some_name.yaml>|wc -l

datacube -v product add ~/.config/madmex/indexing/s2_l2a_20m_granule.yaml

datacube -v dataset add /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/<some_name_20m.yaml>

#before execution of next line check ip of scheduler doing a:

cat /shared_volume/scheduler.json

#also make sure that file ~/.config/madmex/ingestion/s2_l2a_20m_s3_mexico.yaml has in entry 'bucket' the name: test-read-write-jalisco-s2-2018-2

datacube -v ingest --queue-size 10000 -c ~/.config/madmex/ingestion/s2_l2a_20m_s3_mexico.yaml --executor distributed <ip_of_scheduler>:8786

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

4)Apply recipe of 20m product

#first run: 30 dask worker each 115 gb in 30 instances r4.4xlarge, and scheduler 3 gb 
#second run: scheduler of 6gb and 1 dask worker of 230 gb in 1 r4.8xlarge instance

antares apply_recipe -recipe s2_20m_s3_001 -b 2018-01-01 -e 2018-12-31 -region Jalisco --name s2_20m_scl_Jalisco_from_s3_to_s3_2_recipe_2018 -sc /shared_volume/scheduler.json


5)Apply recipe of 10m product

#first run: scheduler of 1gb and 119gb for dask-workers, 20 dask-workers in 20 r4.4xlarge instances
#second run: scheduler of 3gb and 235gb for 1 dask-worker in 1 r4.8xlarge instance

antares apply_recipe -recipe s2_10m_scl_ndvi_mean_001 -b 2018-01-01 -e 2018-12-31 -region Jalisco --name s2_10m_scl_Jalisco_from_s3_to_s3_2_recipe_2018 -sc /shared_volume/scheduler.json

6)Model fit to result of recipe of 20m product (data resampled to 10m in datacube ingest cmd line)

#18gb scheduler, 6gb workers, r4.xlarge, 20 nodes, 35 dask-workers (could be 40 dask-workers)

antares model_fit -model rf -p s2_20m_scl_Jalisco_from_s3_to_s3_2_recipe_2018 -t <name of training data> --region Jalisco --sample <percentage of sample> --remove-outliers --name rf_s2_jalisco_from_s3_to_s3_2_20m_2018 -extra n_estimators=60 -sc /shared_volume/scheduler.json

7)Segmentation to result of recipe of 10m product

#2gb scheduler, 13gb workers, r4.xlarge, 20 nodes, 35 dask-workers (could be 40 dask-workers)

#before next command check how much free storage DB has

antares segment --algorithm bis -n s2_10m_Jalisco_seg_from_s3_to_s3_2_2018 -p s2_10m_scl_Jalisco_from_s3_to_s3_2_recipe_2018 -r Jalisco -b ndvi_mean --datasource sentinel_2 --year 2018 -extra t=40 s=0.5 c=0.7 -sc /shared_volume/scheduler.json

#after segment check how much free storage DB has

8)Predict of result of segmentation of 10m product

#2gb scheduler, 14gb workers, r4.xlarge, 20 nodes, 35 dask-workers (could be 40 dask-workers)

antares model_predict_object -p s2_20m_scl_Jalisco_from_s3_to_s3_2_recipe_2018 -m rf_s2_jalisco_from_s3_to_s3_2_20m_2018 -s s2_10m_Jalisco_seg_from_s3_to_s3_2_2018 -r Jalisco --name land_cover_rf_jalisco_from_s3_to_s3_2_s2_10m_2018 -sc /shared_volume/scheduler.json

9)Convert to raster result of 8)

#29gb for scheduler no dask workers in a r4.xlarge instance (node)

antares db_to_raster -n land_cover_rf_jalisco_from_s3_to_s3_2_s2_10m_2018 -region Jalisco -f land_cover_rf_jalisco_from_s3_to_s3_2_s2_10m_2018.tif --resolution 10 -p '+proj=lcc +lat_1=17.5 +lat_2=29.5 +lat_0=12 +lon_0=-102 +x_0=2500000 +y_0=0 +a=6378137 +b=6378136.027241431 +units=m +no_defs'

10) Validation

#not sure how much ram... possibly 29gb in a scheduler of a r4.xlarge instance

antares validate -c land_cover_rf_jalisco_from_s3_to_s3_2_s2_10m_2018 -val bits_interpret -r Jalisco --comment 'validation for Jalisco s2 10m 2018 using bits_interpret and reading from s3 input images'

