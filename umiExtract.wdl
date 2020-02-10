version 1.0
workflow umiExtract {
  input {
    File fastq1
    File fastq2
    String regexKeyword
    File regexFile = "/.mounts/labs/gsi/testdata/umiExtract/regex/regex.txt"
    String outputLogNamePrefix = basename("~{fastq1}", "R1_001.fastq.gz")
  } 
    
  call getRegexExpression {
    input: regexKeyword = regexKeyword,
           regexFile = regexFile
  }  

  call extractUMI {
    input: 
      fastq1 = fastq1, 
      fastq2 = fastq2, 
      regexExpression = getRegexExpression.regexExpression,
      regexKeyword = regexKeyword,
      regexFile = regexFile,
      outputLogNamePrefix = outputLogNamePrefix
  }

  meta {
    author: "Rishi Shah"
    email: "rshah@oicr.on.ca"
    description: "Using extract function of UMI-tools; extracting UMIs from the sequence and adding them them as identifiers to a read"
    dependencies: 
    [
      {
        name: "umi-tools/1.0.0",
        url: "https://github.com/CGATOxford/UMI-tools"
      }
    ]
    output_meta: {
      fastq1Out: "Outputted fastq file with extracted UMIs from input file 1",
      fastq2Out: "Outputted fastq file with extracted UMIs from input file 2",
      logOut: "Log with statistics from umi extraction"
    }
  }

  output {
    File fastq1Out = extractUMI.outputFastq1
    File fastq2Out = extractUMI.outputFastq2
    File logOut = extractUMI.outputLog
  }
}



task getRegexExpression {
  input {
    String regexKeyword
    File regexFile
    Int jobMemory = 8
    Int threads = 4
    Int timeout = 6
  }

  parameter_meta {
    regexKeyword: "Keyword to get regex expression"
    regexFile: "File that the regex expressions are stored in"
    jobMemory: "Memory allocated for this job"
    threads: "Requested CPU threads"
    timeout: "hours before task timeout"
  }

  command <<<
    grep '${regexKeyword}' ${regexFile}
  >>>

  runtime {
    memory:  "~{jobMemory} GB"
    cpu:     "~{threads}"
    timeout: "~{timeout}"
  }

  output {
    String regexExpression = basename(stdout())
  }

  meta {
    output_meta: {
      regexExpression: "Stores the regexExpression"
    }
  }
}



task extractUMI {
  input {
    File fastq1
    File fastq2
    String outputLogNamePrefix
    String outFileName1 = basename("~{fastq1}", ".fastq.gz")
    String outFileName2 = basename("~{fastq2}", ".fastq.gz")
    String regexKeyword 
    String regexFile
    String regexExpression
    String method = "regex"
    String savePath = "./output"
    String modules = "umi-tools/1.0.0 htslib/1.9"
    Int jobMemory = 8
    Int threads = 4
    Int timeout = 6
  }

  parameter_meta {
    fastq1: "First fastq input file containing reads"
    fastq2: "Second fastq input file containing reads"
    outFileName1: "Name for the output file derived from input file fastq1"
    outFileName2: "Name for the output file derived from the input file fastq2"
    outputLogNamePrefix: "Name for the output log file"
    regexExpression: "Regular experession telling the extract function what to do"
    method: "Using a regular expression as the extract method parameter"
    savePath: "Path to save the guppy output"
    modules: "Module needed to run UMI-tools extract"
    jobMemory: "Memory allocated for this job"
    threads: "Requested CPU threads"
    timeout: "hours before task timeout"
  }

  command <<<
    umi_tools extract --extract-method=~{method} \
                      --bc-pattern=~{regexExpression} \
                      --stdin=~{fastq1} \
                      --stdout=~{outFileName1}.umi.fastq \
                      --read2-in=~{fastq2} \
                      --read2-out=~{outFileName2}.umi.fastq \
                      --log=~{outputLogNamePrefix}.log
    bgzip ~{outFileName1}.umi.fastq
    bgzip ~{outFileName2}.umi.fastq
  >>>

  runtime {
    modules: "~{modules}"
    memory:  "~{jobMemory} GB"
    cpu:     "~{threads}"
    timeout: "~{timeout}"
  }

  output {
    File outputFastq1 = "~{outFileName1}.umi.fastq"
    File outputFastq2 = "~{outFileName2}.umi.fastq"
    File outputLog = "~{outputLogNamePrefix}.log"
  }

  meta {
    output_meta: {
      outputFastq1: "Output fastq file with extracted UMIs from input file 1",
      outputFastq2: "Output fastq file with extracted UMIs from input file 2",
      outputLog: "Log file outputs"
    }
  }
}
