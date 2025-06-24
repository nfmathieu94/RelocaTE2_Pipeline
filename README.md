# RelocaTE2_Pipeline
A pipeline to run RelocaTE2 to identify mPing and Ping insertions from short reads.


## Outline
Pipelines include:
1. Download, trim raw fastq files with `fastp`, and align with `bwa-mem`
    * Alignment files will be used for CharacTErizer step in RelocaTE2
2. Run `RepeatMasker` using mPing, Ping, and Pong sequence
3. Run RelocaTE2
    * Do this with mPing and Ping sequences individually
    * The parameters used for mPing and Ping differ in the mismatch threshold used
4. Run `CallPing.py` to get Ping calls from mixed results 
5. Filter and concatenate mPing results
    * Filter inludes keeping known parental insertions, valid TSD, and junction read support 
6. Concatenate Ping results
