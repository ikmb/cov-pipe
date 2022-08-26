process COVERAGE_STATS {

        label 'default'

        tag "${meta.sample_id}"

        publishDir "${params.outdir}/${meta.sample_id}/BAM", mode: 'copy'

        input:
        tuple val(meta),path(bam),path(bai)

        output:
	tuple val(meta),path(global_dist), emit: mosdepth
	tuple val(meta),path(sam_coverage), emit: samtools
	tuple val(meta),path(report), emit: jpg

        script:
        global_dist = meta.sample_id + ".mosdepth.global.dist.txt"
        sam_coverage = meta.sample_id + ".coverage.samtools.txt"
        report = meta.sample_id + ".jpg"
        base_name = meta.sample_id

        """
                mosdepth -t ${task.cpus} ${meta.sample_id} $bam
                samtools depth -d 200  $bam > $sam_coverage
                bam2coverage_plot.R $sam_coverage $base_name
        """

}

