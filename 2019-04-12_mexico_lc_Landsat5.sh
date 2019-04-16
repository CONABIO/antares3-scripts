#buckets that will hold data ingestion process:

#srtm:
datacube-srtm-mexico-s3

datacube-ls5-7-espa-mexico-s3

#database to use in both .antares and .datacube.conf 

antares_datacube 

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

datacube -v ingest --queue-size < > -c ~/.config/madmex/ingestion/ls5_espa_mexico.yaml --executor distributed <ip_scheduler>:8786


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


######################(end) 1)ingest:


######################2)recipe:

#95 and 96 will be used


######################(end)2)recipe:



