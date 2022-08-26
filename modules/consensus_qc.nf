process CONSENSUS_QC {

        publishDir "${params.outdir}/${meta.sample_id}/QC", mode: 'copy'

        tag "${meta.sample_id}"

        input:
        tuple val(meta),path(consensus_reheader)

        output:
        tuple val(meta),path(stats), emit: stats

        script:
        stats = meta.sample_id + "_assembly_report.txt"

        """
                assembly_stats.pl -i $consensus_reheader > $stats
        """
}
