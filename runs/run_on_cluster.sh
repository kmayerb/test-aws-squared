#! bin/bash
ml nextflow 

BATCHFILE=s3_test_manifest.csv
NFCONFIG=aws_cluster.config
PROJECT=aws2-test
OUTPUT_FOLDER=pub
WORK_DIR=work

NXF_VER=19.10.0 nextflow \
    -c $NFCONFIG \
    run \
    kmayerb/test-aws-squared\
        -r 0.0.1\
        --batchfile $BATCHFILE \
        --output_folder $OUTPUT_FOLDER \
        -with-report $PROJECT.html \
        -work-dir $WORK_DIR \
        -with-tower