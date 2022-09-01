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
require '/home/sukmb352/git/cov-pipe/assets/gem/virus_db.rb'
require 'zlib'
require 'rest-client'

### Define modules and classes here

@min_cov = 95.0
@max_n = 5.0

@sources = {
        "10" => "UKSH Kiel",
        "20" => "UKSH Lübeck"
}

def check_status(data)

        n_frac = data["Assembly"]["Anteil_Ns"]
        assembly_len = data["Assembly"]["Laenge"]
        assembly_gaps = data["Assembly"]["Gaps"]
        gap_frac =  assembly_gaps.to_f/assembly_len.to_f
        gap_frac = 100-(gap_frac*100)

        status = true
        if ( n_frac > @max_n || gap_frac < @min_cov)
                status = false
        end

        return status
end

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

data = VirusDB::Sample.all.group_by{|s| s.run_date }.sort_by {|k,v| k }.reverse

this = data.shift
last = data.shift
other = data

failed ={ "this" => 0, "previous" => 0, "older" => 0} 

bucket = {}

this_date = this.shift
this_samples = this.shift

last_date = last.shift
last_samples = last.shift

other_samples = []
other.each do |o,samples|
	samples.each {|s| other_samples << s }
end

sets = { "this" => this_samples, "previous" => last_samples, "older" => other_samples }

bucket_template = {"this" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 }, "previous" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 }, "older" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 } }

sets.each do |k,samples|

	samples.each do |sample|

		json = JSON.parse(Zlib.inflate(sample.json))
		valid = check_status(json)
	
		if !valid
			failed[k] += 1
			next
		end

		source = "other"

		if sample.external_id
			stub = sample.external_id[0..1]
			if @sources.has_key?(stub)
				source = @sources[stub]
			end
		end

		p = sample.pangolin_lineage

		if bucket.has_key?(p)	
			bucket[p][k][source] += 1 
		else
			bucket[p] = {"this" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 }, "previous" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 }, "older" => { "UKSH Kiel" => 0, "UKSH Lübeck" => 0, "other" => 0 } }
			bucket[p][k][source] += 1
		end

	end
end

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
