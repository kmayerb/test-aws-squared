#! bin/bash

# Reference database
BATCHFILE=s3_files/manifest.csv
NFCONFIG=configs/local.config
PROJECT=aws2-test
OUTPUT_FOLDER=pub
WORK_DIR=work

nextflow \
    -c $NFCONFIG \
    run \
    kmayerb/test-aws-squared\
        -r 0.0.1\
        --batchfile $BATCHFILE \
        --output_folder $OUTPUT_FOLDER \
        -work-dir $WORK_DIR \
