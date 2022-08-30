process PANGOLIN_VERSION {

        executor 'local'

        label 'pangolin'

        output:
        path(pangolin_version), emit: version

        script:
        pangolin_version = "v_pangolin.txt"

        """
                pangolin -v > $pangolin_version
        """
}

process FREEBAYES_VERSION {

        executor 'local'

        label 'freebayes'

        output:
        path(freebayes_version), emit: version

        script:
        freebayes_version = "v_freebayes.txt"

        """
                freebayes --version &> v_freebayes.txt
        """

}

process FASTP_VERSION {

        label 'fastp'

        executor 'local'

        output:
        path("v_fastp.txt"), emit: version

        script:

        """
                fastp -v &> v_fastp.txt
        """
}

process SOFTWARE_VERSIONS {

    label 'default'

    publishDir "${params.outdir}/Summary/versions", mode: 'copy'

    input:
    path('*')

    output:
    path("v*.txt"), emit: txt
    path(yaml_file), emit: yaml
    path(tab_file), emit: tab

    script:
    yaml_file = "software_versions_mqc.yaml"
    tab_file = "software_versions.tab"

    """
            echo $workflow.manifest.version &> v_ikmb_virus_pipe.txt
            echo $workflow.nextflow.version &> v_nextflow.txt
            samtools --version &> v_samtools.txt
            bcftools --version &> v_bcftools.txt
            bwa &> v_bwa.txt 2>&1 || true
            parse_versions.pl >  $yaml_file
            parse_versions_tab.pl > $tab_file
    """
}
