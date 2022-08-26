process VCF_FILTER {

        label 'bcftools'

        tag "${meta.sample_id}"

        input:
        tuple val(meta),path(vcf)

        output:
        tuple val(meta),path(vcf_filtered), emit: vcf

        script:
        vcf_filtered = vcf.getBaseName() + ".filtered.vcf"

        """
                bcftools filter -e 'INFO/MQM < ${params.var_filter_mqm} | INFO/SAP > ${params.var_filter_sap} | QUAL < ${params.var_filter_qual}'  $vcf > $vcf_filtered
        """
}

