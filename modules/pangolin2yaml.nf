process PANGOLIN2YAML {

        label 'default'

        publishDir "${params.outdir}/Pangolin", mode: 'copy'

        input:
        path(reports)
        path(pangolin_json)

        output:
        path(report), emit: yaml
        path(xls), emit: xls
        path(csv), emit: csv

        script:

        report = "pangolin_report_mqc.yaml"
        xls = "pangolin." + params.run_name + ".xlsx"
        csv = "pangolin." + params.run_name + ".csv"

        """
                pangolin2yaml.pl --alias $pangolin_json > $report
                pangolin2xls.pl --alias $pangolin_json --outfile $xls > $csv
        """

}

