#!/usr/bin/env ruby
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
require 'prawn'
require 'date'

### Define modules and classes here

def qopt_to_matrix(lines)

	bin = {}
	answer = {}

	header = lines.shift.split(" ")

	# Qopt has results in line 2, even if bootstrapping is done
	results = lines.shift.strip.split(" ")

	header.each_with_index do |k,i|
		answer[k] = (results[i].to_f*100).to_i
	end

	return answer
end

### Get the script arguments and open relevant files
options = OpenStruct.new()
opts = OptionParser.new()
opts.banner = "A script description here"
opts.separator ""
opts.on("-n","--name", "=NAME", "Name of sample") {|argument| options.name = argument }
opts.on("-c","--coverage", "=COVERAGE", "Coverage stats") {|argument| options.coverage = argument }
opts.on("-p", "--pangolin", "=PANGOLIN, "Pangolin results") {|argument| options.pangolin = argument }
opts.on("-s","--stats", "=STATS", "Stats") {|argument| options.stats = argument }
opts.on("-o","--outfile", "=OUTFILE","Output file") {|argument| options.outfile = argument }
opts.on("-h","--help","Display the usage information") {
 puts opts
 exit
}

opts.parse! 

## Parse pangolin results
pango_type = "undetermined"

lines = IO.readlines(options.pangolin)

## Parse Coverage data


## Parse sequencing stats




###########################
## Generate PDF report 
###########################

date = Date.today.strftime("%d.%m.%Y")

footer = "Bericht erstellt am: #{date}"

pdf = Prawn::Document.new

pdf.font("Helvetica")
pdf.font_size 14

pdf.text "Sars-Cov2 Typing mittels Genomsequenzierung"

pdf.move_down 5
pdf.stroke_horizontal_rule

pdf.font_size 10
pdf.move_down 5
pdf.text "Probe: #{options.name}"
pdf.move_down 5
pdf.text "Qualität: OK"
pdf.move_down 5 
pdf.text "Pangolin lineage: #{pango_type}"
pdf.move_down 20



pdf.move_cursor_to 40
pdf.stroke_horizontal_rule
pdf.move_down 10
pdf.font_size 8
pdf.text "Es werden nur Ergebnisse mit einem Anteil von mindestens #{threshold}% gezeigt."
pdf.move_down 5
pdf.text footer

pdf.render_file("#{sample_name}_report.pdf")
