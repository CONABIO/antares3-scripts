###for ingestion we need to map s3 to a nfs using gateway and file-share services of AWS:

#Using next autoscaling group already created in AWS we can ingest sentinel data to datacube

#m4.4xlarge-sge-ingest-on-datacube-asgp-2

#for master:
#runcommand


#!/bin/bash
##variables
user=ubuntu
source /home/$user/.profile
eip=<eip alloc of elastic IP>
name_instance=conabio-sge-master
efs_dns=<dns of efs subnet conabio>
nfs_ip_s3=<ip of file-share-gateway>
bucket=conabio-s3-oregon
mount_point_2=/shared_volume_s3
mkdir $mount_point_2
##Name of the queue that will be used by dask-scheduler and dask-workers
queue_name=dask-queue.q
##Change number of slots to use for every instance, in this example the instances have 2 slots each of them
slots=1
region=$region
type_value=$type_value
##Mount shared volume
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $efs_dns:/ $mount_point
mount -t nfs -o nolock,hard $nfs_ip_s3:/$bucket $mount_point_2
mkdir -p $mount_point/datacube/datacube_ingest
##Tag instance
INSTANCE_ID=$(curl -s http://instance-data/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s http://instance-data/latest/meta-data/public-ipv4)
##Assining elastic IP where this bash script is executed
aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id $eip --region $region
##Tag instance where this bash script is executed
aws ec2 create-tags --resources $INSTANCE_ID --tag Key=Name,Value=$name_instance-$PUBLIC_IP --region=$region
##Execute bash script create-dask-sge-queue already created on Dependencies-Cloud Deployment
bash $mount_point/create-dask-sge-queue.sh $queue_name $slots


#for node:

#!/bin/bash
user=ubuntu
source /home/$user/.profile
##Ip for sun grid engine master
master_dns=$(cat $mount_point/ip_master.txt)
echo $master_dns > /var/lib/gridengine/default/common/act_qmaster
/etc/init.d/gridengine-exec restart


#on host:

sudo docker run -p 8787:8787 --name antares3-scheduler -e GDAL_DATA=/usr/share/gdal/2.2/ -v /shared_volume:/shared_volume -v /shared_volume_s3/:/shared_volume_s3/ -dit madmex/antares3-k8s-cluster-dependencies:v5 /bin/bash -c "pip3 install --user git+https://github.com/CONABIO/antares3.git@develop --upgrade --no-deps && /home/madmex_user/.local/bin/antares init && /usr/local/bin/dask-scheduler --port 8786 --bokeh-port 8787 --scheduler-file /shared_volume/scheduler.json"

cd /shared_volume/tasks/2018/mapa_base_2018_s2/

#deploy multiple workers (13 in this case):

qsub -t 1-13 -cwd -S /bin/bash launch_antares3_workers.sh

sudo docker exec -it antares3-scheduler bash

datacube -v system init --no-init-users

#modify: /shared_volume/tasks/2018/mapa_base_2018_s2/shell_prepare_metadata.sh according to path

#shell_prepare_metadata.sh:

#!/bin/bash
sudo docker exec antares3-scheduler /bin/bash -c "source ~/.profile && antares prepare_metadata --path MEX_S2_preprocessed/2018 --bucket conabio-s3-oregon --dataset_name s2_l2a_20m --outfile /shared_volume/tasks/2018/mapa_base_2018_s2/metadata_mexico_s2_20m_s3_2018_bucket_2.yaml --multi 13"

qsub -l h=$HOSTNAME -cwd -S /bin/bash shell_prepare_metadata.sh

#just do a substitution to write the right path pointing to mapping of s3 to nfs:

sed -n 's/s3:\/\/conabio-s3-oregon/\/shared_volume_s3/;p' metadata_mexico_s2_20m_s3_2018_bucket_2.yaml > metadata_mexico_s2_20m_s3_2018_bucket.yaml

#count how many datasets are going to be ingested
grep id: metadata_mexico_s2_20m_s3_2018_bucket.yaml|wc -l

sudo docker exec -it antares3-scheduler bash

antares init

datacube -v product add ~/.config/madmex/indexing/s2_l2a_20m_granule.yaml

datacube -v dataset add /shared_volume/tasks/2018/mapa_base_2018_s2/metadata_mexico_s2_20m_s3_2018_bucket.yaml

#ingest_datacube.sh

#!/bin/bash

sudo docker exec antares3-scheduler /bin/bash -c "source ~/.profile && datacube -v ingest -c ~/.config/madmex/ingestion/s2_l2a_20m_s3_mexico.yaml --executor distributed 172.17.0.2:8786"

#before launching next command modify entry 'bucket' for datacube-s2-20m-resampled-mexico-s3 in ~/.config/madmex/ingestion/s2_l2a_20m_s3_mexico.yaml :

qsub -l h=$HOSTNAME -cwd -S /bin/bash ingest_datacube.sh


#ingest 10m data:

#In scheduler container:

#modify: /shared_volume/tasks/2018/mapa_base_2018_s2/shell_prepare_metadata_10m.sh according to path

#shell_prepare_metadata_10m.sh

#!/bin/bash
sudo docker exec antares3-scheduler /bin/bash -c "source ~/.profile && antares prepare_metadata --path MEX_S2_preprocessed/2018 --bucket conabio-s3-oregon --dataset_name s2_l2a_10m_scl --outfile /shared_volume/tasks/2018/mapa_base_2018_s2/metadata_mexico_s2_10m_s3_2018_bucket_2.yaml --multi 13

qsub -l h=$HOSTNAME -cwd -S /bin/bash shell_prepare_metadata.sh

#just do a substitution to write the right path pointing to mapping of s3 to nfs:

sed -n 's/s3:\/\/conabio-s3-oregon/\/shared_volume_s3/;p' metadata_mexico_s2_10m_s3_2018_bucket_2.yaml > metadata_mexico_s2_10m_s3_2018_bucket.yaml

#count how many datasets are going to be ingested

grep id: metadata_mexico_s2_10m_s3_2018_bucket.yaml|wc -l

datacube -v product add ~/.config/madmex/indexing/s2_l2a_10m_scl_granule.yaml

datacube -v dataset add /shared_volume/tasks/2018/mapa_base_2018_s2/metadata_mexico_s2_10m_s3_2018_bucket.yaml

#ingest_datacube_10m.sh

#!/bin/bash

sudo docker exec antares3-scheduler /bin/bash -c "source ~/.profile && datacube -v ingest -c ~/.config/madmex/ingestion/s2_l2a_10m_scl_s3_mexico.yaml --executor distributed 172.17.0.2:8786"

#before launching next command modify entry 'bucket' datacube-s2-10m-mexico-s3 in ~/.config/madmex/ingestion/s2_l2a_10m_scl_s3_mexico.yaml:


qsub -l h=$HOSTNAME -cwd -S /bin/bash ingest_datacube_10m.sh


#ingest srtm


#shell_prepare_metadata_srtm.sh

#!/bin/bash
sudo docker exec antares3-scheduler /bin/bash -c "source ~/.profile && antares prepare_metadata --path dem/srtm_90 --bucket conabio-s3-oregon --dataset_name srtm_cgiar --outfile /shared_volume/tasks/2018/mapa_base_2018_s2/metadata_srtm_bucket.yaml -sc /shared_volume/scheduler.json

qsub -l h=$HOSTNAME -cwd -S /bin/bash shell_prepare_metadata_srtm.sh

datacube -v product add ~/.config/madmex/indexing/srtm_cgiar.yaml

#Added "srtm_cgiar_mosaic"

datacube -v dataset add /shared_volume/tasks/2018/mapa_base_2018_s2/metadata_srtm_bucket.yaml


#on host:

ingest_datacube_srtm_cgiar.sh

#!/bin/bash

sudo docker exec antares3-scheduler /bin/bash -c "source ~/.profile && datacube -v ingest -c ~/.config/madmex/ingestion/srtm_cgiar_mexico.yaml --executor distributed 172.17.0.2:8786"

#before launching next command modify entry 'bucket' datacube-srtm-mexico-s3 in ~/.config/madmex/ingestion/srtm_cgiar_mexico.yaml:


qsub -l h=$HOSTNAME -cwd -S /bin/bash ingest_datacube_srtm_cgiar.sh


#On kubernetes cluster (deployment)

##############apply recipe:

#10m:

#antares3-scheduler 2gb and for antares3-workers 14 gb is enough, 19 dask-workers in 10 r4.xlarge instances  #using dask chunks x,y equal to 5000 and no time parameter 

#bounding box for Mexico

antares apply_recipe -recipe s2_10m_scl_ndvi_mean_001 -b 2018-01-01 -e 2018-12-31 -lat 14 32.91 -long -117.68 -85.73 --name s2_10m_scl_mexico_s3_recipe_2018 -sc /shared_volume/scheduler.json

#20m:

#bounding box for Mexico

antares apply_recipe -recipe s2_20m_s3_001 -b 2018-01-01 -e 2018-12-31 -lat 14 32.91 -long -117.68 -85.73 --name s2_20m_scl_mexico_s3_recipe_2018 -sc /shared_volume/scheduler.json


#next antares commands for Jalisco 2018 (test)

##################segmentation (2gb scheduler, 14gb workers, r4.xlarge, 10 nodes, 19 dask-workers) 


antares segment --algorithm bis -n s2_10m_Jalisco_test_seg_2018 -p s2_10m_scl_mexico_s3_recipe_2018 -r Jalisco -b ndvi_mean --datasource sentinel_2 --year 2018 -extra t=40 s=0.9 c=0.7 -sc /shared_volume/scheduler.json

##################model fit (18gb scheduler, 6gb workers, r4.xlarge, 10 nodes, 28 dask-workers)

antares model_fit -model rf -p s2_20m_scl_mexico_s3_recipe_2018 -t jalisco_bits --region Jalisco --sample 0.3 --remove-outliers --name rf_s2_jalisco_test_20m_2018 -extra n_estimators=60 -sc /shared_volume/scheduler.json

################### Model predict (2gb scheduler, 14gb workers, r4.xlarge, 10 nodes, 19 dask-workers)

antares model_predict_object -p s2_20m_scl_mexico_s3_recipe_2018 -m rf_s2_jalisco_test_20m_2018 -s s2_10m_Jalisco_test_seg_2018 -r Jalisco --name land_cover_rf_jalisco_test_s2_10m_2018 -sc /shared_volume/scheduler.json


################### #db to raster:(29 gb for scheduler-r4.xlarge, the amount of ram is not clear if its 29,tests for 16 gb didn't work, no workers)

mkdir -p /shared_volume/tasks/2018/landcover/

cd /shared_volume/tasks/2018/landcover/


antares db_to_raster -n land_cover_rf_jalisco_test_s2_10m_2018 -region Jalisco -f land_cover_rf_jalisco_test_s2_10m_2018.tif --resolution 10 -p '+proj=lcc +lat_1=17.5 +lat_2=29.5 +lat_0=12 +lon_0=-102 +x_0=2500000 +y_0=0 +a=6378137 +b=6378136.027241431 +units=m +no_defs'


aws s3 cp land_cover_rf_jalisco_test_s2_10m_2018.tif s3://conabio-s3-oregon/antares3_products/landcover/sentinel/jalisco/2nd_tests/


