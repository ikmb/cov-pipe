process VCF_NORMALIZE {

        publishDir "${params.outdir}/${meta.sample_id}/Variants", mode: 'copy'

        tag "${meta.sample_id}"

        label 'default'

        input:
        tuple val(meta),path(vcf)
        path(ref_genome)

        output:
        tuple val(meta),path(vcf_filtered)
        tuple val(meta),path(vcf_filtered_gz),path(vcf_filtered_tbi), emit: vcf

        script:

        vcf_filtered = vcf.getBaseName() + ".normalized.vcf"
        vcf_filtered_gz = vcf_filtered + ".gz"
        vcf_filtered_tbi = vcf_filtered_gz + ".tbi"

        """
                vt normalize -o tmp.vcf -r $ref_genome $vcf

                adjust_gt_rki.py -o $vcf_filtered --vf $params.cns_gt_adjust $vcf
                bgzip -c $vcf_filtered > $vcf_filtered_gz
                tabix $vcf_filtered_gz
        """

}

