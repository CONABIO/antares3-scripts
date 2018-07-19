# Ingest 6 scenes over Jalisco
antares prepare_metadata --path linea_base/L8 --bucket conabio-s3-oregon --dataset_name landsat_espa --outfile /shared_volume/metadata_landsat_bucket.yaml --pattern ".*LC080(30046|29046|28046|29045|28045|30045)(2017|2014).*" --multi 10
datacube -v product add ~/.config/madmex/indexing/landsat_8_espa_scenes.yaml
datacube -v dataset add /shared_volume/metadata_landsat_bucket.yaml
datacube ingest -c ~/.config/madmex/ingestion/ls8_espa_mexico.yaml --executor distributed <scheduler_ip>

# INgest SRTM DEM
antares prepare_metadata --path dem/srtm_90 --bucket conabio-s3-oregon --dataset_name srtm_cgiar --outfile /shared_volume/metadata_srtm_bucket.yaml
datacube -v product add ~/.config/madmex/indexing/srtm_cgiar.yaml
datacube -v dataset add /shared_volume/metadata_srtm_bucket.yaml
datacube ingest -c ~/.config/madmex/ingestion/srtm_cgiar_mexico.yaml --executor distributed <scheduler_ip>

# Run apply recipe for 2014 and 2017
antares apply_recipe -recipe landsat_8_madmex_002 -b 2017-01-01 -e 2017-12-31 --region Jalisco --name landsat_recipe_002_jalisco_2017 -sc /shared_volume/scheduler.json
antares apply_recipe -recipe landsat_8_madmex_002 -b 2014-01-01 -e 2014-12-31 --region Jalisco --name landsat_recipe_002_jalisco_2014 -sc /shared_volume/scheduler.json

# Run segmentation over 2014 and 2017
antares segment --algorithm bis -n landsat_2014 -p landsat_recipe_002_jalisco_2014 -r Jalisco -b ndvi_mean ndmi_mean --datasource landsat --year 2014 -extra t=30 s=0.5 c=0.7 -sc /shared_volume/scheduler.json
antares segment --algorithm bis -n landsat_2017 -p landsat_recipe_002_jalisco_2017 -r Jalisco -b ndvi_mean ndmi_mean --datasource landsat --year 2017 -extra t=30 s=0.5 c=0.7 -sc /shared_volume/scheduler.json

# Train a model for each year
antares model_fit -model lgb -p landsat_recipe_002_jalisco_2014 -t persistent_test --region Jalisco --name lgb_landsat_jalisco_2014 --sample 0.3 --remove-outliers -extra n_estimators=150 -sc /shared_volume/scheduler.json
antares model_fit -model lgb -p landsat_recipe_002_jalisco_2017 -t persistent_test --region Jalisco --name lgb_landsat_jalisco_2017 --sample 0.3 --remove-outliers -extra n_estimators=150 -sc /shared_volume/scheduler.json

# Model predict
antares model_predict_object -p landsat_recipe_002_jalisco_2014 -m lgb_landsat_jalisco_2014 -s landsat_2014 -r Jalisco --name lc_jalisco_landsat_2014 -sc /shared_volume/scheduler.json
antares model_predict_object -p landsat_recipe_002_jalisco_2017 -m lgb_landsat_jalisco_2017 -s landsat_2017 -r Jalisco --name lc_jalisco_landsat_2017 -sc /shared_volume/scheduler.json

# Land cover change
antares detect_change --product_pre landsat_recipe_002_jalisco_2014 \
        --product_post landsat_recipe_002_jalisco_2017 \
        --lc_pre lc_jalisco_landsat_2014 \
        --lc_post lc_jalisco_landsat_2017 \
        --year_pre 2014 \
        --year_post 2017 \
        --algorithm distance \
        --name jalisco_2014_2017 \
        --bands ndvi_mean ndmi_mean \
        --mmu 5000 \
        --region Jalisco \
        -sc /shared_volume/scheduler.json
