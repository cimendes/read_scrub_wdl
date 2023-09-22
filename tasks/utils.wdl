version 1.0

task count_reads {
  input {
    File read1
    File read2
    String samplename
    String docker
    Int disk_size = 100
    Int cpu = 4
    Int mem = 8
  }
  command <<<
    python3 <<CODE
    import argparse
    import gzip

    def contains_only_n(input_string):
      return input_string.count("N") == len(input_string)

    def count_reads(input_file1, input_file2):
      read_count = 0
      with gzip.open(input_file, 'rt') as f1, gzip.open(input_file2, 'rt') as f2:
        for header1, header2 in zip(f1, f2):
          header1 = header1.strip()
          header2 = header2.strip()
          seq1 = f1.readline().strip()
          seq2 = f2.readline().strip()
          plus1 = f1.readline().strip()
          plus2 = f2.readline().strip()
          qual1 = f1.readline().strip()
          qual2 = f2.readline().strip()
          if not contains_only_n(seq1) and not contains_only_n(seq2):
            read_count += 1

        return read_count
      
    read_count_pairs = count_reads(~{read1}, ~{read2})
    
    with open("READ_COUNT", "w") as f:
      f.write(str(read_count_pairs))
    CODE 
  >>>
  output {
    Int read_count_pairs = read_int("READ_COUNT")
  }
  runtime {
    docker: docker
    memory: "~{mem} GB"
    cpu: cpu
    disks:  "local-disk " + disk_size + " SSD"
    disk: disk_size + " GB" # TES
    preemptible: 0
    maxRetries: 3
  }
}