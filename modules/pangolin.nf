process PANGOLIN {

        label 'pangolin'

        publishDir "${params.outdir}/${meta.sample_id}/Pangolin", mode: 'copy'

        tag "${meta.sample_id}"

        input:
        tuple val(meta),path(assembly)

        output:
        tuple val(meta),path(report), emit: report
	path("versions.yml"), emit: version

        script:
	def options = ""
	if (params.pango_data) {
		options = "--datadir ${params.pango_data}"
	}		
        report = meta.sample_id + ".pangolin.csv"
        aln = meta.sample_id + ".ref_alignment.fasta"

        """
                pangolin $options -t ${task.cpus} --outfile $report $assembly

      cat <<-END_VERSIONS > versions.yml
      "${task.process}":
            pangolin \$( pangolin -v )
      END_VERSIONS

        """
}

