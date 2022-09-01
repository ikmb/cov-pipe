process CSV2XLS {

	label 'default'

	publishDir "${params.outdir}/WeeklyReport", mode: 'copy'

	input:
	path(tab)

	output:
	path(xls)

	script:
	xls = tab.getBaseName() + ".xls"

	"""
		csv2xls -d '\t' -o $xls $tab 
	"""

}
