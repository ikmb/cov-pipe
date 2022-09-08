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
require 'rest-client'

### Define modules and classes here

@sources = {
        "10" => "UKSH Kiel",
        "20" => "UKSH Lübeck"
}

def percentage(this,total)

        if total > 0
                return ((this.to_f/total.to_f)*100).round
        else
                return 0
        end

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

VirusDB::DBConnection.connect(options.db)

runs = VirusDB::Run.order(run_date: :desc).all.to_a

# The run from this week, last week, and all previous runs
this = runs.shift
last = runs.shift
other = runs

# Count failed samples per time slot
failed ={ "this" => 0, "previous" => 0, "older" => 0} 

bucket = {}

this_date = this.run_date
this_samples = this.samples

last_date = last.run_date
last_samples = last.samples

other_samples = []
other.each do |oruns|
	oruns.samples.each {|s| other_samples << s }
end

sets = { "this" => this_samples, "previous" => last_samples, "older" => other_samples }

bucket_template = {"this" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 }, "previous" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 }, "older" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 } }

# Iterate over weeks. 
sets.each do |k,samples|

	samples.each do |sample|

		json = JSON.parse(Zlib.inflate(sample.json))

		source = "other"

		if sample.external_id
			stub = sample.external_id[0..1]
			if @sources.has_key?(stub)
				source = @sources[stub]
			end
		end

		pass = sample.pass?
		warn "#{sample.sample_id}\t#{pass}"

		p = "None"
		if pass
			call = sample.get_latest_pango_call
			call ? p = call.pangolin_lineage : p = "None"
		else
			p = "ZZ-Failed"
		end

		if bucket.has_key?(p)	
			bucket[p][k][source] += 1 
		else
			bucket[p] = {"this" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 }, "previous" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 }, "older" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 } }
			bucket[p][k][source] += 1
		end

	end
end

###################
# Print everything
###################

puts "\tAktuell #{this_date}\t\t\t\t\t\t\tVorwoche #{last_date}\t\t\t\t\t\t\t\tAltdaten"

columns = "Gesamt\tUKSH Kiel\tUKSH Kiel %\tUKSH Lübeck\tUKSH Lübeck %\tAndere\tAndere %"
puts "Lineage\t#{columns}\t#{columns}\t#{columns}"

summary = {"this" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 }, "previous" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 }, "older" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 } }

bucket.sort_by {|pango,data| pango }.each do |pango,data|

	next if !pango || pango.length < 2

	total = 0
	overall = 0

	data.each do |week,info|
		info.each do |i,c|
			summary[week][i] += c
		end
	end

	this = data["this"]	
	previous = data["previous"]
	older = data["older"]

	result = "#{pango}"

	[ this, previous, older ].each do |d|

		total = 0
		d.each do |k,v|
			total += v
		end
		overall += total
		
		result +=  "\t#{total}\t#{d['UKSH Kiel']}\t#{percentage(d['UKSH Kiel'],total)}%\t#{d['UKSH Lübeck']}\t#{percentage(d['UKSH Lübeck'],total)}%"

		result += "\t#{d['other']}\t#{percentage(d['other'],total)}%"

	end

	puts result

end

s = "Summary"

this_s = summary["this"]
last_s = summary["previous"]
older_s = summary["older"]

[ this_s, last_s, older_s ].each do |d|

	total = 0
        d.each do |k,v|
		total += v
        end

	s += "\t#{total}\t#{d['UKSH Kiel']}\t#{percentage(d['UKSH Kiel'],total)}%\t#{d['UKSH Lübeck']}\t#{percentage(d['UKSH Lübeck'],total)}%"

        s += "\t#{d['other']}\t#{percentage(d['other'],total)}%"

end

puts s
