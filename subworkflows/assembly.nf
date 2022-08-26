include { BEDTOOLS_MASK } from './../modules/bedtools/mask'
include { BCFTOOLS_CONSENSUS }  from './../modules/bcftools/consensus'
include { CONSENSUS_HEADER } from './../modules/consensus_header'
include { CONSENSUS_QC } from './../modules/consensus_qc'

ch_versions = Channel.from([])

workflow ASSEMBLY {

	take:
	variants
	bam
	genome

	main:
	
	BEDTOOLS_MASK(
		bam.join(variants)
	)

	BCFTOOLS_CONSENSUS(
		variants.join(BEDTOOLS_MASK.out.bed),
		genome.collect()
	)

	CONSENSUS_HEADER(
		BCFTOOLS_CONSENSUS.out.fasta
	)

	CONSENSUS_QC(
		CONSENSUS_HEADER.out.fasta
	)

	emit:
	versions = ch_versions
	fasta = CONSENSUS_HEADER.out.fasta
	stats = CONSENSUS_QC.out.stats
}
