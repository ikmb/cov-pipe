#!/usr/bin/ruby
# == NAME
# script_skeleton.rb
#
# == USAGE
# ./this_script.rb [ -h | --help ]
#[ -i | --infile ] |[ -o | --outfile ] | 
# == DESCRIPTION
# A skeleton script for Ruby
#
# == OPTIONS
# -h,--help Show help
# -i,--infile=INFILE input file
# -o,--outfile=OUTFILE : output file

#
# == EXPERT OPTIONS
#
# == AUTHOR
#  Marc Hoeppner, mphoeppner@gmail.com

require 'optparse'
require 'ostruct'
require 'json'
require File.dirname(__FILE__) + "/../assets/gem/virus_db.rb"
require 'zlib'

### Define modules and classes here

def get_metadata(sample)

        url = "#{$server}/get_diagnostic_job_date"
        data = { "knumber" => sample }
        json = data.to_json
        response = RestClient::Request.execute(
                method: :get,
                url: url,
                payload: json,
                headers: { content_type: 'application/json', accept: 'application/json'}
        )

        JSON.parse(response)

end

### Get the script arguments and open relevant files
options = OpenStruct.new()
opts = OptionParser.new()
opts.banner = "A script description here"
opts.separator ""
opts.on("-d","--db", "=DB", "Sqlite DB file") { |argument| options.db = argument }
opts.on("-h","--help","Display the usage information") {
 puts opts
 exit
}

opts.parse! 

$server = "http://172.21.99.123/IBDBase_Interface/api"

unless File.exist?(options.db)
	abort "Could not find the specified flatfile database! (--db)"
end

fastas = Dir["*.fasta"]
jsons = Dir["*.json"]

VirusDB::DBConnection.connect(options.db)

fastas.each do |fasta| 

	base_id = fasta.split(".")[0]

	warn base_id

	j = jsons.find{|f| f.include?(base_id) }

	if j

		puts "Running ${fasta} <-> #{j}"

	        json = JSON.parse(IO.readlines(j).join)

		blob = Zlib.deflate(IO.readlines(fasta).join)
		jblob = Zlib.deflate(IO.readlines(j).join)		

		library = json["Sample"]["library"]
		external_id = nil

		if library.match(/^K[0-9].*/)
			meta = get_metadata(library.split("-")[0])
			if meta.has_key?("external_id")
				external_id = meta["external_id"]
			end
		end

		entry = VirusDB::Sample.create(
        		sample_id: json["Sample"]["library"],
	        	pangolin_lineage: json["Pangolin"]["lineage"],
	        	pangolin_lineage_full: json["Pangolin"]["voc"],
		        coverage_20X: json["reads"]["coverage_20X"],
			external_id = external_id
			json: jblob,
        		pipeline_version: json["Version"],
			run_date: json["run_date"],
		        reference: json["Reference"],
        		sequence: blob
		)
		entry.save

		pangolin = VirusDB::Pangolin.create(
			sample_id: entry.id,
			pangolin_version: json["Software"]["pangolin"],
			pangolin_lineage: json["Pangolin"]["lineage"]
		)
		pangolin.save

	else

		warn "Missing JSON for #{base_id}"

	end

end 


