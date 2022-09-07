process WEEKLY_REPORT {

	label 'default'

	publishDir "${params.outdir}/WeeklyReport", mode: 'copy'

	input:
	path(trigger)
	path(db)

	output:
	path(report), emit: tab

	script:
	report = params.run_name + "-" + params.run_date + ".weekly.txt"

	"""
		weekly_report.rb -d ${db} > $report
	"""

}
