process REPORT {

        label 'default'

        tag "${meta.sample_id}"

        publishDir "${params.outdir}/Reports", mode: 'copy'

        input:
        tuple val(meta),path(pangolin),path(samtools),path(fasta_qc),path(variants),path(coverage_plot),path(mosdepth)
	path(versions)

        output:
        tuple val(meta),path(patient_report), emit: pdf
        tuple val(meta),path(patient_report_json), emit: json
        tuple val(meta),path(patient_report_txt), emit: txt

        script:

        patient_report = meta.sample_id + "_report.pdf"
        patient_report_json = meta.sample_id + "_report.json"
        patient_report_txt = meta.sample_id + "_variants.txt"

        """
                cp $baseDir/assets/ikmb_bfx_logo.jpg .
                covid_report.pl --patient $meta.sample_id \
			--id $meta.library_id \
			--software $versions \
                        --pangolin $pangolin \
                        --depth $mosdepth \
                        --bam_stats $samtools \
                        --assembly_stats $fasta_qc \
			--run_date $params.run_date \
                        --vcf $variants \
                        --plot $coverage_plot \
                        --outfile $patient_report > $patient_report_json

                json2txt.pl --infile $patient_report_json > $patient_report_txt
        """

}

