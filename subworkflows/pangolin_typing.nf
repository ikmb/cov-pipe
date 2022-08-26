include { PANGOLIN } from './../modules/pangolin'
include { PANGOLIN2YAML } from './../modules/pangolin2yaml'
include { PANGOLIN_LOOKUP } from './../modules/pangolin_lookup'

ch_versions = Channel.from([])

workflow PANGOLIN_TYPING {

	take:
	fasta

	main:

	PANGOLIN(
		fasta
	)
	ch_versions = ch_versions.mix(PANGOLIN.out.version)
	
	PANGOLIN_LOOKUP()

	PANGOLIN2YAML(
		PANGOLIN.out.report.map {m,r -> r }.collect(),
		PANGOLIN_LOOKUP.out.json.collect()
	)

	emit:
	report = PANGOLIN.out.report
	yaml = PANGOLIN2YAML.out.yaml
	csv = PANGOLIN2YAML.out.csv
	versions = ch_versions
}
