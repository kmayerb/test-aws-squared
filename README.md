# test-aws-squared

Test New AWS Squared NF Paradigm With Something Really Simple

## Test Local

This works locally. 

```bash
#! bin/bash
BATCHFILE=s3_files/manifest.csv
NFCONFIG=local.config
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
```

```
N E X T F L O W  ~  version 19.10.0
Launching `kmayerb/test-aws-squared` [friendly_picasso] - revision: 70f8a8aee0 [0.0.1]
executor >  local (2)
[c6/292681] process > REVERSE (Reverse Sequences in a Fasta File) [100%] 2 of 2 ✔
```


Given config

```bash
process.executor = 'local'

docker {
    enabled = false
    temp = 'auto'
}
```

## Test on Cluster 


s3_manifest.csv
```
name,filename
ATGG,s3:/fh-pi-kublin-j-microbiome/read_only/REF/ATGG.fasta
ATCG,s3:/fh-pi-kublin-j-microbiome/read_only/REF/ATCG.fasta
```

runs/run_on_cluster.sh
```
ml nextflow 

BATCHFILE=s3_test_manifest.csv
NFCONFIG=aws_cluster.config
PROJECT=aws2-test
OUTPUT_FOLDER=s3:/fh-pi-kublin-j-microbiome/scratch-delete30/testpub
WORK_DIR=s3:/fh-pi-kublin-j-microbiome/scratch-delete30/testwork

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

```

aws.config
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



## Test on AWS Squared