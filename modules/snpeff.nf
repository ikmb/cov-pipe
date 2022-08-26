process SNPEFF {

        label 'default'

        tag "${meta.sample_id}"

        publishDir "${params.outdir}/${meta.sample_id}/Variants", mode: 'copy'

        input:
        tuple val(meta),path(vcf),path(tbi)

        output:
        tuple val(meta),path(effects), emit: vcf

        script:

        effects = meta.sample_id + ".snpeff." + params.ref_name + ".vcf"

        """
                snpEff -v $params.ref_name -onlyProtein -no-upstream -no-downstream -canon $vcf > $effects
        """

}

