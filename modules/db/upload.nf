process DB_UPLOAD {

	label 'default'

	input:
	path(jsons)
	path(fastas)

	when: 
	params.sqlite_db

	output:
	path(log_file), emit: log

	script:
	log_file = params.run_name + ".sql.log"

	"""
		upload.rb -d ${params.sqlite_db} > $log_file
	"""	

}
