process RKI_METADATA {

        label 'default'

        executor 'local'

        publishDir "${params.outdir}/RKI_Assemblies/00PASS", mode: 'copy'

        when:
        params.metadata

        input:
        path('*')

        output:
        path(metadata), emit: metadata

        script:
        metadata = run_name + ".metadata.csv"

        """
                ikmb_metadata.pl > $metadata
        """

}

