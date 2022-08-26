include { FASTP } from './../modules/fastp'
include { BWA_MEM } from './../modules/bwa/mem'
include { MERGE_MULTI_LANE; BAM_INDEX ; BAM_INDEX as BAM_INDEX_FILTERED ; DEDUP ; AMPLICON_CLIP ; SAMTOOLS_STATS } from "./../modules/samtools/main"
include { COVERAGE_STATS } from './../modules/coverage_stats'

ch_versions = Channel.from([])

workflow ALIGN {

	take:
	reads
	bwa_index
	
	main:

        FASTP(
           reads
        )

	ch_versions = ch_versions.mix(FASTP.out.version)

        BWA_MEM(
                FASTP.out.reads,
                bwa_index.collect()
        )
	
	ch_versions = ch_versions.mix(BWA_MEM.out.version)

        bam_mapped = BWA_MEM.out.bam.map{ meta, bam ->
		new_meta = [:]
                new_meta.sample_id = meta.sample_id
                def groupKey = meta.sample_id
                tuple( groupKey, new_meta, bam)
        }.groupTuple(by: [0,1]).map{ g, new_meta, bam -> [ new_meta, bam ] }

        bam_mapped.branch {
  	      single:   it[1].size() == 1
              multiple: it[1].size() > 1
        }.set { bam_to_merge }

        MERGE_MULTI_LANE( bam_to_merge.multiple )
        BAM_INDEX(
		MERGE_MULTI_LANE.out.bam.mix( bam_to_merge.single )
	)

        DEDUP(
                BAM_INDEX.out.bam
        )

	SAMTOOLS_STATS(
		DEDUP.out.bam
	)

	COVERAGE_STATS(
		BAM_INDEX.out.bam
	)

	emit:
	bam = DEDUP.out.bam
	stats = SAMTOOLS_STATS.out.stats
	mosdepth = COVERAGE_STATS.out.mosdepth
	samtools_depth = COVERAGE_STATS.out.samtools
	json = FASTP.out.json
	jpg = COVERAGE_STATS.out.jpg
	versions = ch_versions

}
