version 1.0

workflow umiExtract {
input {
 File fastq1
 File fastq2
 String outFileNamePrefix1
 String outFileNamePrefix2
 String logNamePrefix
 String regex 

}
call extractUMI {input: fastq1 = fastq1, fastq2 = fastq2, outFileNamePrefix1 = outFileNamePrefix1, outFileNamePrefix2 = outFileNamePrefix2, logNamePrefix = logNamePrefix, regex = regex}

meta {
 author: "Rishi Shah"
 email: "rshah@oicr.on.ca"
 description: "Using extract function of UMI-tools; extracting UMIs from the sequence and adding them them as identifiers to a read"
 dependencies: [
      {
        name: "umi-tools/1.0.0",
        url: "https://github.com/CGATOxford/UMI-tools"
      },

      {
        name: "python/3.6",
        url: "https://www.python.org/downloads/release/python-360/" 
      }
    ]
}


output {
  File fastq1Out = extractUMI.outputFastq1
  File fastq2Out = extractUMI.outputFastq2
 }

meta {
    output_meta: {
      fastq1Out: "Outputted fastq file with extracted UMIs from input file 1",
      fastq2Out: "Outputted fastq file with extracted UMIs from input file 2"
    }
}

}

task extractUMI {
input {
    File fastq1
    File fastq2
    String outFileNamePrefix1
    String outFileNamePrefix2
    String logNamePrefix
    String regex 
    String method = "regex"
    String modules = "umi-tools/1.0.0 python/3.6"
    Int jobMemory = 8
    Int threads = 4
    Int timeout = 4

}

parameter_meta {
    fastq1: "First fastq input file containing reads"
    fastq2: "Second fast q input file containing reads"
    outFileNamePrefix1: "Name for the output file derived from input file fastq1"
    outFileNamePrefix2: "Name for the output file derived from the input file fastq2"
    logNamePrefix: "Name for the output log file"
    regex: "Regular experession telling the extract function what to do"
    method: "Using a regular expression as the extract method parameter"
    modules: "Module needed to run UMI-tools extract"
    jobMemory: "Memory allocated for this job"
    threads: "Requested CPU threads"
    timeout: "hours before task timeout"
}

command <<<
    umi_tools extract --extract-method=~{method} \
                    --bc-pattern=~{regex} \
                    --stdin=~{fastq1} \
                    --stdout=~{outFileNamePrefix1}.fastq \
                    --read2-in=~{fastq2} \
                    --read2-out=~{outFileNamePrefix2}.fastq \
                    --log=~{logNamePrefix}.log
>>>

runtime {
  modules: "~{modules}"
  memory:  "~{jobMemory} GB"
  cpu:     "~{threads}"
  timeout: "~{timeout}"
}

output {
    File outputFastq1 = "~{outFileNamePrefix1}.fastq"
    File outputFastq2 = "~{outFileNamePrefix2}.fastq"
}

meta {
    output_meta: {
      outputFastq1: "Output fastq file with extracted UMIs from input file 1",
      outputFastq2: "Output fastq file with extracted UMIs from input file 2"
    }
}
}
