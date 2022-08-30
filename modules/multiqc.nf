process MULTIQC {

   label 'multiqc'

   publishDir "${params.outdir}/MultiQC", mode: 'copy'

   container 'depot.galaxyproject.org-singularity-multiqc-1.13a--pyhdfd78af_1'

   input:
   path('*')

   output:
   path('*.html'), emit: html

   script:

   """
      cp ${baseDir}/assets/multiqc_config.yaml . 
      multiqc . 
   """	

}


