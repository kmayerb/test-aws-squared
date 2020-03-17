# test-aws-squared

Test New AWS Squared NF Paradigm With Something Really Simple

<https://github.com/FredHutch/nextflow-aws-batch-squared>

* METHOD 1: Run headnode and nexflowjobs completely Locally 
* METHOD 2: Run from headnode on FH Rhino or Gizmo, with jobs on AWS batch
* METHOD 3: Run headnode from AWS batch, with jobs also on AWS batch

## METHOD 1: LOCAL 

Given `configs/local.config`

```bash
process.executor = 'local'

docker {
    enabled = false
    temp = 'auto'
}
```

This works locally. 

runs/run_local.sh
```bash
#! bin/bash
BATCHFILE=manifests/manifest.csv
NFCONFIG=configs/local.config
PROJECT=aws2-test
OUTPUT_FOLDER=pub
WORK_DIR=work

nextflow \
    -c $NFCONFIG \
    run \
    kmayerb/test-aws-squared\
        -r 0.0.3\
        --batchfile $BATCHFILE \
        --output_folder $OUTPUT_FOLDER \
        -work-dir $WORK_DIR \
```

```
N E X T F L O W  ~  version 19.10.0
Launching `kmayerb/test-aws-squared` [friendly_picasso] - revision: 70f8a8aee0 [0.0.1]
executor >  local (2)
[c6/292681] process > REVERSE (Reverse Sequences in a Fasta File) [100%] 2 of 2 ✔
```


## METHOD 2:

Now your mainfest.csv file neeeds to point to s3 objects

s3_manifest.csv
```
name,filename
ATGG,s3:/fh-pi-kublin-j-microbiome/read_only/REF/ATGG.fasta
ATCG,s3:/fh-pi-kublin-j-microbiome/read_only/REF/ATCG.fasta

```

With `aws_cluster.config`

```
process.executor = 'awsbatch'
// // Run the analysis on the specified queue in AWS Batch

process.queue = 'cpu-spot-40'
// // Run in the correct AWS region


// // Mount the host folder /docker_scratch to /tmp within the running job
// // Use /tmp for scratch space to provide a larger working directory
// // Replace with the Job Role ARN for your account
aws {
    region = 'us-west-2'
    batch {
        cliPath = '/home/ec2-user/miniconda/bin/aws'
        jobRole = 'arn:aws:iam::IAMTOKEN:role/ROLETOKEN'
        volumes = ['/docker_scratch:/tmp:rw']
    }
}

tower {
  accessToken = TOWERTOKEN
  enabled = true
}

process {
    withName: 'REVERSE' {
        errorStrategy = {task.attempt <= 3 ? 'retry' : 'finish'}
        memory = {1.GB * task.attempt}
        maxRetries = 3
        cpus = 1
        time = {1.h * task.attempt}
    }
}
```


runs/run_on_cluster.sh
```
ml nextflow 

BATCHFILE=manifests/s3_test_manifest.csv
NFCONFIG=configs/aws_cluster.config
PROJECT=aws2-test
OUTPUT_FOLDER=s3:/fh-pi-kublin-j-microbiome/scratch-delete30/testpub
WORK_DIR=s3:/fh-pi-kublin-j-microbiome/scratch-delete30/testwork

NXF_VER=19.10.0 nextflow \
    -c $NFCONFIG \
    run \
    kmayerb/test-aws-squared\
        -r 0.0.4\
        --batchfile $BATCHFILE \
        --output_folder $OUTPUT_FOLDER \
        -with-report $PROJECT.html \
        -work-dir $WORK_DIR \
        -with-tower

```

## METHOD 3: HEAD NODE ON AWS Batch

<https://github.com/FredHutch/nextflow-aws-batch-squared>

```
git clone https://github.com/FredHutch/nextflow-aws-batch-squared.git --branch v0.0.14
```

This is the new paradigm where the head node is also on AWS not on a cluster. 
Therefore you must also but all these elements on S3 so the head node can 
access them.

Checklist of things to put on S3"

* params.json - params for the workflow
* .config - configuration for the workflow
* mainfiest.csv - input file list


### Setup everything on S3.

All the following should be in S3: 

#### params.json

params.json allows you specify params used by the nextflow script

```json
{
	"batchfile":"s3:/fh-pi-kublin-j-microbiome/read_only/REF/s3_test_manifest.csv",
	"output_folder":"s3:/fh-pi-kublin-j-microbiome/scratch-delete30/testpub"
}
```

#### .config

Edit with your `TOWER_TOKEN` and `IAMTOKEN` and `ROLETOKEN`

```bash
process.executor = 'awsbatch'
// // Run the analysis on the specified queue in AWS Batch

process.queue = 'cpu-spot-50'
// // Run in the correct AWS region


// // Mount the host folder /docker_scratch to /tmp within the running job
// // Use /tmp for scratch space to provide a larger working directory
// // Replace with the Job Role ARN for your account
aws {
    region = 'us-west-2'
    batch {
        cliPath = '/home/ec2-user/miniconda/bin/aws'
        jobRole = 'arn:aws:iam::IAMTOKEN:role/ROLETOKEN'
        volumes = ['/docker_scratch:/tmp:rw']
    }
}

docker {
    enabled = true
    temp = 'auto'
}

tower {
  accessToken = 'TOWER_TOKEN'
  enabled = true
}

process {
    withName: 'REVERSE' {
        errorStrategy = {task.attempt <= 2 ? 'retry' : 'finish'}
        memory = {1.GB * task.attempt}
        maxRetries = 2
        cpus = 1
        time = {1.h * task.attempt}
    }
}
```

### manifest.csv

Note the params.json points you toward: `s3:/fh-pi-kublin-j-microbiome/read_only/REF/s3_test_manifest.csv`

```
name,filename
ATGG,s3:/fh-pi-kublin-j-microbiome/read_only/REF/ATGG.fasta
ATCG,s3:/fh-pi-kublin-j-microbiome/read_only/REF/ATCG.fasta
```

### configure run.py 

Edit with your `TOWER_TOKEN` and `JOB_ROLE_ARN`

Note: RESTART_UUID can be any random sequence

Note: --watch allows you to see some progress reporting

#### do_run.sh

```bash
WORKFLOW=kmayerb/test-aws-squared
REVISION=0.0.4
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
    --watch
```

This ran. Here is what ended up in the scratch-delete30 bucket. 

* testpub/
* test-sq-report
* test-sq-work/efb5215b8232f42b2e79de42ec75913e/



