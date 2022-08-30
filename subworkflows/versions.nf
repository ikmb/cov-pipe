include { SOFTWARE_VERSIONS; FREEBAYES_VERSION; PANGOLIN_VERSION; FASTP_VERSION } from './../modules/versions.nf'

ch_versions = Channel.from([])

workflow VERSIONS {

	main:

	PANGOLIN_VERSION()
	ch_versions = ch_versions.mix(PANGOLIN_VERSION.out.version)
	FASTP_VERSION()
        ch_versions = ch_versions.mix(FASTP_VERSION.out.version)
	FREEBAYES_VERSION()
	ch_versions = ch_versions.mix(FREEBAYES_VERSION.out.version)
	SOFTWARE_VERSIONS(ch_versions.collect())

	emit:
	versions = SOFTWARE_VERSIONS.out.tab
} 
