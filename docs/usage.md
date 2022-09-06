# Usage information

This pipeline can process Illumina short reads from sequenced viral cDNA, Metatranscriptomes or similar to:

* clean/trim reads
* align reads against a defined reference (virus or virus+human)
* variant calling against viral reference + normalization + filtering
* create RKI-compliant consensus assembly (ref-flipping)
* lineage-typing using Pangolin

## Basic execution

Assuming an config file exists (default = Medcluster of the IKMB), the following commend will start the pipeline (nextflow and singularity must be available in the PATH):

`nextflow run ikmb/cov-pipe --reads '/path/to/*_R{1,2}_001.fastq.gz'`

For more details on available options, see below.

## Available options and settings

### `--folder` 
Path to a folder containing Illumina PE reads. Will automatically group files into libraries and lanes. Assumes the CCGA (standard Illumina´) naming scheme: `*_L0*_R{1,2}_001.fastq.gz`. Mutually exclusive with `--reads` and `--samples`.

### `--samples`
Path to a CSV formatted sample sheet as an alternative to --reads. Expects the following columns:

```
sample_id,library_id,readgroup_id,R1,R2
21Ord1339,21Ord1339-L1,21Ord1339-L1_L001,/path/to/reads_R1_001.fastq.gz,/path/to/reads_R2_001.fastq.gz
```

A script is included with this code base to produce such a file from a folder of fastQ files

Mutually exclusive with `--folder`. 

```
ruby /path/to/samplesheet_from_folder.rb -f /path/to/folder > Samples.csv
```

You can edit this file to replace the library-derived labels for IndivID and/or SampleID with an order number or patient ID. 

### `--run_name`
Provide a usefull name to this analysis run (could be the LIMS project ID)

### `--outdir` (default: results)
A folder name to which all outputs are written. This can also be a path (relative or absolute) - the target location with be created if necessary. 

### `--db`
A SQLite database flatfile (pre-configured for our environment)

### `--clean` (default: false)
Overwrite the existing run in the database (--db)

### `--clip` (default: 20)
Remove n bases from both 3' and 5' of each read to account for fragmented amplicon primers that cannot be detected otherwise.

### `--primer_set` (default: ARTIC-v3)
Defines which set of PCR primers was used if this is sequenced from amplicons using Illumina (ARTIC-v3 or Eden). This option is likely not useful if the library prep fragments/nicks the adapters and/or reads are generated from fragmented amplicons. If this is the case, the option `--clip` should be used to simply trim off bases from the ends of all reads to remove potential PCR primer contamination. 

### `--primer_fasta` (default: false)
Provide a set of primer sequences in FASTA format (overrides --primer_set option)

### `--var_call_cov` (default: 10)
Minimum coverage at a site required for analysis

### `--var_call_count` (default: 10)
Minimum number of reads required to support a SNP call

### `---var_call_frac` (default: 0.1)
Minimum fraction of reads required to call a SNP

### `--var_filter_mqm` (default: 40)
Minimum mean mapping quality required for a variant to pass

### `--var_filter_sap` (default: 2000)
Maximum strand bias probability to include a variant call (note: this value may not be useful with amplicon data - hence the high default!)

### `--var_filer_qual` (default: 10)
Mimum call quality to include a variant

### `--metadata`
Enables an additional process that retrieves sample-specific meta data to produce a RKI compatible meta data sheet. This uses an in-house script and only works on the IKMB infrastructure. It is enabled by default on systems that support this option. 

### `--ref_with_host`
The base name of a BWA formatted index containing a human genome sequence together with the Sars-CoV2 [genome](../assets/reference/NC_045512.2.fa). This is used to have decoys for mapping and variant calling. If this is not set, the built-in viral reference genome is used only.  
This should be fine, we have not yet seen a clear advantage of using a combined reference when working off amplicon data (this might be different for metagenomic data). 

