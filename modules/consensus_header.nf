process CONSENSUS_HEADER {

        publishDir "${params.outdir}/RKI_Assemblies", mode: 'copy'

        label 'default'

        tag "${meta.sample_id}"

        input:
        tuple val(meta),path(consensus)

        output:
        tuple val(meta),path(consensus_reheader), emit: fasta
        tuple val(meta),path(consensus_masked_reheader), emit: fasta_masked

        script:
        base_id = meta.sample_id.split("-")[0]
        consensus_reheader = base_id + ".fasta"
        consensus_masked_reheader = base_id + ".masked.fasta"

        header = base_id
        masked_header = base_id
        description = meta.sample_id.split("-")[1..-1].join("-")

        """
                echo '>$header' > $consensus_reheader
                tail -n +2 $consensus | fold -w 80 >> $consensus_reheader
                echo  >> $consensus_reheader

                echo '>$masked_header' > $consensus_masked_reheader

                tail -n +2 $consensus | tr "RYSWKMBDHVN" "N" | fold -w 80 >> $consensus_masked_reheader
                echo >> $consensus_masked_reheader
        """

}
