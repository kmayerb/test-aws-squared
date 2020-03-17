WORKFLOW=kmayerb/test-aws-squared
REVISION=0.0.3
JOB_ROLE_ARN=
JOB_QUEUE=cpu-spot-50
NAME=test-aws-squared-first-try
NF_CONFIG_FILE=s3://fh-pi-kublin-j-microbiome/read_only/REF/kmayerbl-aws-test.config
PARAMS_FILE=s3://fh-pi-kublin-j-microbiome/read_only/REF/aws-test-params.json
WORK_DIR=s3://fh-pi-kublin-j-microbiome/scratch-delete30/test-sq-work
TEMP_VOL=/docker_scratch
RESTART_UUID=efb5215b8232f42b2e79de42ec75913e
NF_VER=20.01.0
REPORT=s3://fh-pi-kublin-j-microbiome/scratch-delete30/test-sq-report/report.html
TRACE=s3://fh-pi-kublin-j-microbiome/scratch-delete30/test-sq-report/trace.html
TOWER_TOKEN=

python run.py \
    --workflow ${WORKFLOW} \
    --revision ${REVISION} \
    --job-role-arn ${JOB_ROLE_ARN} \
    --job-queue ${JOB_QUEUE} \
    --name ${NAME} \
    --config-file ${NF_CONFIG_FILE} \
    --params-file ${PARAMS_FILE} \
    --working-directory ${WORK_DIR} \
    --temporary-volume ${TEMP_VOL} \
    --restart-uuid ${RESTART_UUID} \
    --nextflow-version ${NF_VER} \
    --with-report ${REPORT} \
    --with-trace ${TRACE} \
    --tower-token ${TOWER_TOKEN}


