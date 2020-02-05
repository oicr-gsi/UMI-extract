# umiExtract

Using extract function of UMI-tools; extracting UMIs from the sequence and adding them them as identifiers to a read

## Overview

## Dependencies

* [umi-tools 1.0.0](https://github.com/CGATOxford/UMI-tools)


## Usage

### Cromwell
```
java -jar cromwell.jar run umiExtract.wdl --inputs inputs.json
```

### Inputs

#### Required workflow parameters:
Parameter|Value|Description
---|---|---
`fastq1`|File|First fastq file
`fastq2`|File|Second fastq file
`regex`|String|Regular expression (must be in '')


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`extractUMI.outFileName1`|String|basename("~{fastq1}",".fastq.gz")|Name for the output file derived from input file fastq1
`extractUMI.outFileName2`|String|basename("~{fastq2}",".fastq.gz")|Name for the output file derived from the input file fastq2
`extractUMI.logNamePrefix`|String|"log"|Name for the output log file
`extractUMI.method`|String|"regex"|Using a regular expression as the extract method parameter
`extractUMI.modules`|String|"umi-tools/1.0.0"|Module needed to run UMI-tools extract
`extractUMI.jobMemory`|Int|8|Memory allocated for this job
`extractUMI.threads`|Int|4|Requested CPU threads
`extractUMI.timeout`|Int|6|hours before task timeout


### Outputs

Output | Type | Description
---|---|---
`fastq1Out`|File|Outputted fastq file with extracted UMIs from input file 1
`fastq2Out`|File|Outputted fastq file with extracted UMIs from input file 2


## Niassa + Cromwell

This WDL workflow is wrapped in a Niassa workflow (https://github.com/oicr-gsi/pipedev/tree/master/pipedev-niassa-cromwell-workflow) so that it can used with the Niassa metadata tracking system (https://github.com/oicr-gsi/niassa).

* Building
```
mvn clean install
```

* Testing
```
mvn clean verify \
-Djava_opts="-Xmx1g -XX:+UseG1GC -XX:+UseStringDeduplication" \
-DrunTestThreads=2 \
-DskipITs=false \
-DskipRunITs=false \
-DworkingDirectory=/path/to/tmp/ \
-DschedulingHost=niassa_oozie_host \
-DwebserviceUrl=http://niassa-url:8080 \
-DwebserviceUser=niassa_user \
-DwebservicePassword=niassa_user_password \
-Dcromwell-host=http://cromwell-url:8000
```

## Support

For support, please file an issue on the [Github project](https://github.com/oicr-gsi) or send an email to gsi@oicr.on.ca .

_Generated with wdl_doc_gen (https://github.com/oicr-gsi/wdl_doc_gen/)_
