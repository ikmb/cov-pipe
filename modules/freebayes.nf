process FREEBAYES {

        label 'freebayes'

        tag "${meta.sample_id}"

        publishDir "${params.outdir}/${meta.sample_id}/Variants/Raw", mode: 'copy'

        input:
        tuple val(meta),path(bam),path(bai)
	path(reference)

        output:
        tuple val(meta),path(vcf), emit: vcf
	path("versions.yml"), emit: version

        script:
        base_name = bam.getBaseName()
        vcf = base_name + ".vcf"

        """
           freebayes --genotype-qualities \
                        --min-coverage $params.var_call_cov \
                        --haplotype-length -1 \
                        --min-alternate-fraction $params.var_call_frac \
                        --min-alternate-count $params.var_call_count \
                        --pooled-continuous \
                        -f $reference $bam > $vcf

      cat <<-END_VERSIONS > versions.yml
      "${task.process}":
            Freebayes \$( freebayes --version )
      END_VERSIONS

        """

}

