#buckets that will hold data ingestion process:

#srtm:
datacube-srtm-mexico-s3

datacube-ls5-7-espa-mexico-s3

#database to use in both .antares and .datacube.conf 

antares_datacube #this was created with:
#createdb -h <server db> -U <user> antares_datacube

#on server: aurora

#volume in shared_volume to use that will hold antares prepare_metadata results:

/shared_volume/tasks/2019/mexico_landsat_lc

#0)init datacube: (check .datacube.conf properly configured)

datacube -v system init --no-init-users

######################1)ingest:

#17 r4.2xlarge instances

# scheduler 25 gb, 100 workers with 5 gb each

antares prepare_metadata --path linea_base/L5 --bucket conabio-s3-oregon --dataset_name landsat_espa --outfile metadata_mex_l5.yaml -sc /shared_volume/scheduler.json

#just to have an idea: #count number of datasets that will be ingested:

grep id: /shared_volume/tasks/2019/mexico_landsat_lc/metadata_mex_l5.yaml|wc -l

datacube -v product add ~/.config/madmex/indexing/ls5_espa_scenes.yaml

datacube -v dataset add metadata_mex_l5.yaml

# before running ingest add the bucket name to the yaml file that will store ingestion results. 
#Bucket: datacube-ls5-7-espa-mexico-s3

#also check queue-size....and modify properly. Next line  will launch ? tasks (modify in order to 
#launch more than ? tasks....and we can finish in reasonable hours of work)
#retrieve ip of scheduler by doing a cat /shared_volume/scheduler.json

datacube -v ingest --queue-size <size > -c ~/.config/madmex/ingestion/ls5_espa_mexico.yaml --executor distributed <ip_scheduler>:8786


#MUST DO: After ingesting, change storage class of objects below conabio-s3-oregon/linea_base/L5 to 
#"ONEZONE_IA" IA: infrequent access

#Srtm ingestion:

#scheduler 5 gb, ? workers with 5 gb each

#create yaml in: /shared_volume/tasks/2019/mexico_landsat_lc

antares prepare_metadata --path dem/srtm_90 --bucket conabio-s3-oregon --dataset_name srtm_cgiar --outfile metadata_srtm_bucket.yaml -sc /shared_volume/scheduler.json

datacube -v product add ~/.config/madmex/indexing/srtm_cgiar.yaml


datacube -v dataset add metadata_srtm_bucket.yaml


#retrieve ip of scheduler by doing a cat /shared_volume/scheduler.json

#modify entry bucket of yaml with: 
#datacube-srtm-mexico-s3

datacube -v ingest -c ~/.config/madmex/ingestion/srtm_cgiar_mexico.yaml --executor distributed <ip_scheduler>:8786


######################(end) 1)ingest


######################2)recipe:

#95 and 96 will be used
#will use lat long coordinates of bounding box for Mexico instead of region flag

#30 r4.2xlarge instances. Scheduler 10 gb and workers 57 gb

antares apply_recipe -recipe landsat_madmex_003 -b 1995-01-01 -e 1996-12-31 -lat 14 33 -long -119 -84 --name recipe_mex_L5_9596 -sc /shared_volume/scheduler.json

######################(end)2)recipe


######################3)segmentation:

#modify .antares entries SEGMENTATION_BUCKET and TEMP_DIR for bucket and directory that will have temporary segmentation results
#we are using: segmentation-antares3-results bucket
#check if BIS license is functional 
#directory that will have temporary segmentation results is recommended to be in /home/madmex_user instead of
#/shared_volume/temp to avoid bottlenecks of I/O of every worker writing to a unique location. See:
#https://github.com/CONABIO/antares3/blob/develop/madmex/util/s3.py#L176 then use TEMP_DIR=/home/madmex_user

#scheduler 4 gb and workers 12 gb each

antares segment --algorithm bis -n seg_mex_L5_9596 -p recipe_mex_L5_9596 -lat 14 33 -long -119 -84 -b ndvi_mean --datasource landsat5 --year 1995_1996 -extra t=30 s=0.5 c=0.7 -sc /shared_volume/scheduler.json
Command execution is done in 4803.307151556015 seconds.
######################(end)3)segmentation


######################*)ingest training data

#for every state
#r4.4xlarge instance
#scheduler 118 gb

#for Chihuahua state a r4.8xlarge instance with 238 gb for scheduler was used

antares ingest_training_from_raster /path/to/file.tif --fraction 0.0001 --classes 31 --scheme madmex_31 --year 2015 --name bits_<state_mexico> --field class

#example:
antares ingest_training_from_raster Oaxaca_rapideye_2015_31.tif --fraction -1 --classes 31 --scheme madmex_31--year 2015 --name bits_Oaxaca --field class
Command execution is done in 1357.3208334445953 seconds.
######################(end)*)ingest training data


######################4)model fit:

#to do the model fit to a national level we use next configuration of instances and scheduler and workers

#5 r4.2xlarge instances
#scheduler 4 gb, 50 workers with 4gb each

antares model_fit -model rf -p recipe_mex_L5_9596 -t <name of training data> --region <state of Mexico> --name <name of model per state> --sample <% of training data to be used> --remove-outliers -extra n_estimators=60 -sc /shared_volume/scheduler.json

#example:
antares model_fit -model rf -p recipe_mex_L5_9596 -t bits_Oaxaca --region Oaxaca --name model_rf_oaxaca_L5_9596 --sample 1 --remove-outliers -extra n_estimators=60 -sc /shared_volume/scheduler.json
Command execution is done in 158.65846228599548 seconds.

#Aprox 1:30 hr for national level 

######################(end)4)model fit:


######################5)model predict:
#for every state

#scheduler 4gb, 4 gb each dask worker, 17 dask-workers
antares model_predict_object -p recipe_mex_L5_9596 -m <name of model per state> -s seg_mex_L5_9596 -r <state of Mexico> --name <name of predict to identify it in DB> -sc /shared_volume/scheduler.json

#example:
antares model_predict_object -p recipe_mex_L5_9596 -m model_rf_oaxaca_L5_9596 -s seg_mex_L5_9596 -r Oaxaca --name predict_rf_oaxaca_L5_9596 -sc /shared_volume/scheduler.json
Command execution is done in 375.819700717926 seconds.
######################(end)5)model predict:


######################6)db to raster:

#use TEMP_DIR=/share_volume/temp so scheduler can merge results

#scheduler 10 gb, 4 gb dask workers, 20 dask-workers
antares db_to_raster -n <name of predict to identify it in DB>  -region <state of Mexico> -f <name of result> --resolution 30 -sc /shared_volume/scheduler.json

#example:
antares db_to_raster -n predict_rf_oaxaca_L5_9596 -region Oaxaca -f predict_rf_oaxaca_L5_9596.tif --resolution 30 -sc /shared_volume/scheduler.json
Command execution is done in 73.89225602149963 seconds.
######################(end)6)db to raster:


######################*)ingest validation data

***Pending***

######################(end)*)ingest validation data



