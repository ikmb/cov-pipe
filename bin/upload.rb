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


### Get the script arguments and open relevant files
options = OpenStruct.new()
opts = OptionParser.new()
opts.banner = "A script description here"
opts.separator ""
opts.on("-d","--db", "=DB", "Sqlite DB file") { |argument| options.db = argument }
opts.on("-j","--json", "=JSON","JSON file") {|argument| options.json = argument }
opts.on("-f","--fasta", "=FASTA", "Fasta file") { |argument| options.fasta = argument }
opts.on("-h","--help","Display the usage information") {
 puts opts
 exit
}

opts.parse! 

json = JSON.parse(IO.readlines(options.json).join)

VirusDB::DBConnection.connect(options.db)

blob = Zlib.deflate(IO.readlines(options.fasta).join)

entry = VirusDB::Sample.create(
        sample_id: json["Sample"]["patient"],
        pangolin_lineage: json["Pangolin"]["lineage"],
        pangolin_lineage_full: json["Pangolin"]["voc"],
        coverage_20X: json["reads"]["coverage_20X"],
        pipeline_version: json["Version"],
        reference: json["Reference"],
        sequence: blob
)
entry.save

samples = VirusDB::Sample.all

samples.each do |s|
        puts s.inspect
end


