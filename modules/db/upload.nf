process DB_UPLOAD {

	label 'default'

	input:
	path('*')

	when: 
	params.sqlite_db

	output:
	path log, emit: log

	script:

	"""
		upload.rb -d ${params.sqlite_db}
	"""	

}
