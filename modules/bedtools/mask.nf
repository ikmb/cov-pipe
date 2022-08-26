process BEDTOOLS_MASK {

        publishDir "${params.outdir}/${meta.sample_id}/BAM", mode: 'copy'

        tag "${meta.sample_id}"

        label 'bedtools'

        input:
        tuple val(meta),path(bam),path(bai),path(vcf),path(tbi)

        output:
        tuple val(meta),path(mask), emit: bed
	path("versions.yml"), emit: version

        script:

        mask = meta.sample_id + ".coverage_mask.bed"

        """

                bedtools genomecov -bga -ibam $bam | awk '\$4 < ${params.cns_min_cov}' | bedtools merge > tmp.bed
                bedtools intersect -v -a tmp.bed -b $vcf > $mask
		rm tmp.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedtools: \$(echo \$(bedtools --version 2>&1) | sed 's/^bedtools //')
    END_VERSIONS
        """

}

