include { INPUT_CHECK } from '../modules/input_check'
include { ALIGN } from '../subworkflows/align'
include { ASSEMBLY } from '../subworkflows/assembly'
include { VARIANT_CALLING } from '../subworkflows/variant_calling'
include { SOFTWARE_VERSIONS } from '../modules/software_versions'
include { MULTIQC } from './../modules/multiqc'
include { CONSENSUS_SELECT_PASS } from './../modules/consensus_select_pass'
include { RKI_METADATA } from './../modules/rki_metadata'
include { PANGOLIN_TYPING } from './../subworkflows/pangolin_typing'
include { SNPEFF } from './../modules/snpeff'
include { REPORT } from './../modules/report'

def returnFile(it) {
    // Return file if it exists
    inputFile = file(it)
    if (!file(inputFile).exists()) exit 1, "Missing file in TSV file: ${inputFile}, see --help for more information"
    return inputFile
}

Channel.fromPath(params.ref_with_host)
        .map { fa ->
                def bwa_amb = returnFile(fa + ".amb")
                def bwa_ann = returnFile(fa + ".ann")
                def bwa_btw = returnFile(fa + ".bwt")
                def bwa_pac = returnFile(fa + ".pac")
                def bwa_sa = returnFile(fa + ".sa")
                [ fa, bwa_amb, bwa_ann, bwa_btw, bwa_pac, bwa_sa ]
        }
        .set { BWA_INDEX }

ch_versions = Channel.from([])

genome = Channel.fromPath(file(params.ref_fasta, checkIfExists: true))

samplesheet = Channel.fromPath(params.samples)

workflow COVPIPE {
	
	main:
	INPUT_CHECK(samplesheet)

	ALIGN(
		INPUT_CHECK.out.reads,
		BWA_INDEX
	)

	ch_versions = ch_versions.mix(ALIGN.out.versions)
	
	VARIANT_CALLING(
		ALIGN.out.bam,
		genome
	)
	
	ch_versions = ch_versions.mix(VARIANT_CALLING.out.versions)
	
	SNPEFF(
		VARIANT_CALLING.out.vcf
	)

	ASSEMBLY(
		VARIANT_CALLING.out.vcf,
		ALIGN.out.bam,
		genome
	)

	ch_versions = ch_versions.mix(ASSEMBLY.out.versions)

	CONSENSUS_SELECT_PASS(
		ASSEMBLY.out.fasta.join(ASSEMBLY.out.stats).join(ALIGN.out.mosdepth)
	)

	RKI_METADATA(
		CONSENSUS_SELECT_PASS.out.pass
	)

	PANGOLIN_TYPING(
		ASSEMBLY.out.fasta
	)

	ch_versions = ch_versions.mix(PANGOLIN_TYPING.out.versions)

	SOFTWARE_VERSIONS(
                ch_versions.unique().collectFile(name: "versions_concat.yml")
        )

//	REPORT(
//		PANGOLIN_TYPING.out.report.join(
//			ALIGN.out.stats
//		).join(
//			ASSEMBLY.out.stats
//		).join(
//			SNPEFF.out.vcf
//		).join(
//			ALIGN.out.jpg
//		).join(
//			ALIGN.out.mosdepth
//		),
//		SOFTWARE_VERSIONS.out.versions
//	)
		
        MULTIQC(
           ALIGN.out.json.collect()
        )

	emit:
	qc = MULTIQC.out.html
	
}
