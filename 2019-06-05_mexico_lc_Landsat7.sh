#buckets that will hold data ingestion process:

#srtm:
datacube-srtm-mexico-s3

datacube-ls5-7-espa-mexico-s3

#volume in shared_volume to use that will hold antares prepare_metadata results:

/shared_volume/tasks/2019/mexico_landsat_lc

######################1)ingest:

#17 r4.2xlarge instances

# scheduler 25 gb, 95 workers with 5 gb each

antares prepare_metadata --path linea_base/L7 --bucket conabio-s3-oregon --dataset_name landsat_espa --outfile metadata_mex_l7_1415.yaml --pattern ".*LE07[0-9]{6}(2014|2015).*" -sc /shared_volume/scheduler.json

#just to have an idea: #count number of datasets that will be ingested:

grep id: /shared_volume/tasks/2019/mexico_landsat_lc/metadata_mex_l7_1415.yaml|wc -l

# just once
datacube -v product add ~/.config/madmex/indexing/ls7_espa_scenes.yaml

datacube -v dataset add metadata_mex_l7_1415.yaml

# before running ingest add the bucket name to the yaml file that will store ingestion results. 
#Bucket: datacube-ls5-7-espa-mexico-s3

#also check queue-size....and modify properly. Next line  will launch ? tasks (modify in order to 
#launch more than ? tasks....and we can finish in reasonable hours of work)
#retrieve ip of scheduler by doing a cat /shared_volume/scheduler.json

datacube -v ingest -c ~/.config/madmex/ingestion/ls7_espa_mexico.yaml --executor distributed <ip_scheduler>:8786

# srtm was already ingested

######################(end) 1)ingest

