process MERGE_MULTI_LANE {

	label 'samtools'

	tag "${meta.sample_id}"

        input:
        tuple val(meta), path(aligned_bam_list)

        output:
        tuple val(meta),path(merged_bam), emit: bam

        script:
        merged_bam = meta.sample_id + ".merged.bam"
        merged_bam_index = merged_bam + ".bai"

        """
                        samtools merge -@ 4 $merged_bam ${aligned_bam_list.join(' ')}
        """
}

process SAMTOOLS_STATS {

	label 'samtools'

	tag "${meta.sample_id}"

	input:
	tuple val(meta),path(bam),path(bai)

	output:
	tuple val(meta),path(stats), emit: stats

	script:

	stats = bam.getBaseName() + ".stats"

	"""
		samtools stats $bam > $stats
	"""	

}

process BAM_INDEX {

	label 'samtools'

	tag "${meta.sample_id}"

        input:
        tuple val(meta), path(bam)

        output:
        tuple val(meta), path(bam),path(bam_index), emit: bam

        script:
        bam_index = bam.getName() + ".bai"

        """
                samtools index $bam
        """

}

process DEDUP {

	label 'default'

	tag "${meta.sample_id}"

        publishDir "${params.outdir}/${meta.sample_id}/BAM", mode: 'copy'

        input:
        tuple val(meta),path(bam),path(bai)

        output:
        tuple val(meta), path(bam_md_virus),path(bai_md_virus), emit: bam
        path(bam_md_virus_md5), emit: md5sum

        script:
        def prefix = bam.getBaseName() + ".dedup"
        bam_md_virus = prefix + ".bam"
        bai_md_virus = prefix + ".bam.bai"
        bam_md_virus_md5 = prefix + ".bam.md5"

        """

		samtools dict $params.ref_fasta > header.sam

                samtools sort -m 4G -t 2 -n $bam | samtools fixmate -m - fix.bam
                samtools sort -m 4G -t 2 -O BAM fix.bam | samtools markdup -r - md.bam
                samtools index md.bam

                samtools view -bh -o $bam_md_virus md.bam $params.ref_name
                samtools index $bam_md_virus
		md5sum $bam_md_virus > $bam_md_virus_md5
                rm fix.bam md.bam

        """

}

process AMPLICON_CLIP {

	label 'samtools'

	tag "${meta.sample_id}"

	publishDir "${params.outdir}/${meta.sample_id}/", mode: 'copy'

	input:
	tuple val(meta),path(bam),path(bai)
	path(bed)

	output:
	tuple val(meta),path(bam_masked),path(bam_masked_bai)

	script:
	bam_masked = bam.getBaseName() + ".amplicon_clipped.bam"
	bam_masked_bai = bam_masked + ".bai"

	"""
		samtools ampliconclip -b $bed -o $bam_masked $bam
		samtools index $bam_masked
	"""

}

