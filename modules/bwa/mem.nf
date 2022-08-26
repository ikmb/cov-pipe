process BWA_MEM {

        label 'default'

        tag "${meta.sample_id}|${meta.readgroup_id}"

        input:
        tuple val(meta),path(left),path(right)
        tuple path(fasta),path(bwa_amb),path(bwa_ann),path(bwa_btw),path(bwa_pac),path(bwa_sa)

        output:
        tuple val(meta),path(bam), emit: bam
	path("versions.yml"), emit: version
        script:
        ref_name = fasta.getBaseName()
        bam = meta.readgroup_id + "." + ref_name + ".aligned.bam"
        bai = bam + ".bai"

        """
                samtools dict -a $ref_name -o assembly.dict -s Sars-CoV2 $fasta
                bwa mem -H assembly.dict -M -R "@RG\\tID:${meta.readgroup_id}\\tPL:ILLUMINA\\tSM:${meta.sample_id}\\tLB:${meta.library_id}\\tDS:${fasta}\\tCN:CCGA" \
                        -t ${task.cpus} ${fasta} $left $right \
                        | samtools sort -O bam -o $bam -
                samtools index $bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa: \$(echo \$(bwa 2>&1 | head -n3 | tail -n1) | sed 's/^Version: //')
    END_VERSIONS
	"""
}
