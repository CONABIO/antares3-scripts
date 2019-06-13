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
antares prepare_metadata --path linea_base/L7_complement/2014_NOGAPS --bucket conabio-s3-oregon --dataset_name landsat_espa --outfile metadata_mex_l7_14_comp.yaml -sc /shared_volume/scheduler.json
antares prepare_metadata --path linea_base/L7_complement/2015_NOGAPS --bucket conabio-s3-oregon --dataset_name landsat_espa --outfile metadata_mex_l7_15_comp.yaml -sc /shared_volume/scheduler.json

#just to have an idea: #count number of datasets that will be ingested:

grep id: /shared_volume/tasks/2019/mexico_landsat_lc/metadata_mex_l7_1415.yaml|wc -l

# just once
datacube -v product add ~/.config/madmex/indexing/ls7_espa_scenes.yaml

datacube -v dataset add metadata_mex_l7_1415.yaml
datacube -v dataset add metadata_mex_l7_14_comp.yaml
datacube -v dataset add metadata_mex_l7_15_comp.yaml

# before running ingest add the bucket name to the yaml file that will store ingestion results. 
#Bucket: datacube-ls5-7-espa-mexico-s3

#also check queue-size....and modify properly. Next line  will launch ? tasks (modify in order to 
#launch more than ? tasks....and we can finish in reasonable hours of work)
#retrieve ip of scheduler by doing a cat /shared_volume/scheduler.json

datacube -v ingest -c ~/.config/madmex/ingestion/ls7_espa_mexico.yaml --executor distributed <ip_scheduler>:8786

# srtm was already ingested

######################(end) 1)ingest

######################2)recipe:

#2014 and 2015 will be used
#will use lat long coordinates of bounding box for Mexico instead of region flag

#30 r4.2xlarge instances. Scheduler 10 gb and 29 workers 57 gb

antares apply_recipe -recipe landsat_madmex_003 -b 2014-01-01 -e 2015-12-31 -lat 14 33 -long -119 -84 --name recipe_mex_L7_1415 -sc /shared_volume/scheduler.json

#Aprox 2.5 hrs

######################(end)2)recipe

######################3)segmentation:
#modify .antares entries SEGMENTATION_BUCKET and TEMP_DIR for bucket and directory that will have temporary segmentation results
#we are using: segmentation-antares3-results bucket
#check if BIS license is functional 
#directory that will have temporary segmentation results is recommended to be in /home/madmex_user instead of
#/shared_volume/temp to avoid bottlenecks of I/O of every worker writing to a unique location. See:
#https://github.com/CONABIO/antares3/blob/develop/madmex/util/s3.py#L176 then use TEMP_DIR=/home/madmex_user

#scheduler 4 gb and workers 12 gb each

antares segment --algorithm bis -n seg_mex_L7_1415 -p recipe_mex_L7_1415 -lat 14 33 -long -119 -84 -b ndvi_mean --datasource landsat7 --year 2014_2015 -extra t=30 s=0.5 c=0.7 -sc /shared_volume/scheduler.json

######################(end)3)segmentation



