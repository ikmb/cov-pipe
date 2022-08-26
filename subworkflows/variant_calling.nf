include { FREEBAYES } from './../modules/freebayes'
include { VCF_FILTER } from './../modules/vcf/filter'
include { VCF_NORMALIZE } from './../modules/vcf/normalize'

ch_versions = Channel.from([])

workflow VARIANT_CALLING {

	take:
	bam
	fasta

	main:

	FREEBAYES(
		bam,
		fasta.collect()
	)

	ch_versions = ch_versions.mix(FREEBAYES.out.version)
	
	VCF_FILTER(
		FREEBAYES.out.vcf
	)

	VCF_NORMALIZE(
		VCF_FILTER.out.vcf,
		fasta.collect()
	)

	emit:
	vcf = VCF_NORMALIZE.out.vcf
	versions = ch_versions
}
