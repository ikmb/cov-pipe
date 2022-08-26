process SOFTWARE_VERSIONS {

   publishDir "${params.outdir}/versions", mode: 'copy'	
	
   input:
   path(versions)

   output:
   path('versions.yml')
   path(versions)

   script:
   
   """
      parse_versions.pl > versions.yml
   """

}
