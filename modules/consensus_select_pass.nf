process CONSENSUS_SELECT_PASS {

        publishDir "${params.outdir}/RKI_Assemblies", mode: 'copy'

        tag "${meta.sample_id}"

        input:
        tuple val(meta),path(assembly),path(assembly_stats),path(coverage_stats)

        output:
        path("00PASS/*"), optional: true, emit: pass
        path("00FAIL/*"), optional: true, emit: fail

        script:

        """
                mkdir -p 00PASS
                mkdir -p 00FAIL
                select_pass_assembly.pl --assembly $assembly --assembly_stats $assembly_stats --coverage $coverage_stats
        """
}

