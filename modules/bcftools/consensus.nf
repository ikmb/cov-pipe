process BCFTOOLS_CONSENSUS {

	publishDir "${params.outdir}/${meta.sample_id}/Assembly", mode: 'copy'

        tag "${meta.sample_id}"

        label 'bcftools'

        input:
        tuple val(meta),path(vcf),path(tbi),path(bed)
        path(ref_assembly)

        output:
        tuple val(meta),path(consensus), emit: fasta
	path "versions.yml", emit: version

        script:

        consensus = meta.sample_id + ".consensus_assembly.fa"

        """
                bcftools consensus -I \
                        -o $consensus \
                        -f $ref_assembly \
                        -m $bed \
                        --sample $meta.sample_id \
                        $vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(bcftools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS		

        """
}

