process DB_UPLOAD {

	publishDir "${params.outdir}/logs", mode: 'copy'

	label 'default'

	input:
	path(jsons)
	path(fastas)
	path(db)

	when: 
	params.sqlite_db

	output:
	path(log_file), emit: log
	path(db), emit: db

	script:
	log_file = params.run_name + ".sql.log"

	"""
		upload.rb -d $db -n ${params.run_name} -r ${params.run_date} -v ${workflow.manifest.version} -c $params.clean > $log_file
	"""	

}
