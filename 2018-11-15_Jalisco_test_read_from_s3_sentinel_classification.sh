#test Jalisco 2018 on k8s cluster, data is in s3://conabio-s3-oregon/test_jalisco_2018_sentinel2

1)create a bucket in S3 to hold ingestion process results of datacube, for example test-read-write-jalisco-s2-2018-2

#modify IAM service to read and write to this bucket

2)create a test DB, for example: test_from_s3_to_s3_2

createdb -h <host of DB> -U <user of DB> <name of test DB>

#will prompt for password

3)Start k8s-cluster according to requirements of Ingestion process (first step of land cover steps)

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

datacube -v dataset add /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/<some_name.yaml>

#before execution of next line check ip of scheduler doing a:

cat /shared_volume/scheduler.json

#also make sure that file ~/.config/madmex/ingestion/s2_l2a_20m_s3_mexico.yaml has in entry bucket the name: test-read-write-jalisco-s2-2018-2

datacube -v ingest --queue-size 10000 -c ~/.config/madmex/ingestion/s2_l2a_20m_s3_mexico.yaml --executor distributed <ip_of_scheduler>:8786

2)Ingestion of 10m product

#use for example:6gb for scheduler, 14 gb each dask-worker, 50 m4.xlarge instances

antares prepare_metadata --path test_jalisco_2018_sentinel2 --bucket conabio-s3-oregon --dataset_name s2_l2a_10m_scl --outfile /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/<some_name.yaml> -sc /shared_volume/scheduler.json 

#count number of datasets that will be ingested:

grep id: /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/<some_name_10m.yaml>|wc -l

datacube -v product add ~/.config/madmex/indexing/s2_l2a_10m_scl_granule.yaml

datacube -v dataset add /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/metadata_from_s3_to_s3_10m.yaml

#before execution of next line check ip of scheduler doing a:

cat /shared_volume/scheduler.json

#also make sure that file ~/.config/madmex/ingestion/s2_l2a_10m_scl_s3_mexico.yaml has in entry bucket the name: test-read-write-jalisco-s2-2018-2

datacube -v ingest --queue-size 10000 -c ~/.config/madmex/ingestion/s2_l2a_10m_scl_s3_mexico.yaml --executor distributed <ip_of_scheduler>:8786

3)Ingestion of srtm product

antares prepare_metadata --path dem/srtm_90 --bucket conabio-s3-oregon --dataset_name srtm_cgiar --outfile /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/metadata_srtm_bucket.yaml -sc /shared_volume/scheduler.json

datacube -v product add ~/.config/madmex/indexing/srtm_cgiar.yaml

datacube -v dataset add /shared_volume/tasks/2018/searching_error_in_s3_datacube/from_s3_to_s3_2/metadata_srtm_bucket.yaml

#before execution of next line check ip of scheduler doing a:

cat /shared_volume/scheduler.json

#also make sure that file ~/.config/madmex/ingestion/srtm_cgiar_mexico.yaml has in entry bucket the name: test-read-write-jalisco-s2-2018-2

datacube -v ingest -c ~/.config/madmex/ingestion/srtm_cgiar_mexico.yaml --executor distributed <ip_of_scheduler>:8786 

4)Apply recipe of 20m product

5)Apply recipe of 10m product
