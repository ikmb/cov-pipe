DB_ADAPTER = "sqlite3"
#DB_PATH = "/home/sukmb352/projects/pipelines/virus-pipe/db/covid_db.sqlite"
require 'active_record'
require 'rest-client'
require 'json'

module VirusDB 
  
  class DBConnection < ActiveRecord::Base
  
	self.abstract_class = true
	self.pluralize_table_names = false
  
    	def self.connect(db)
    
			establish_connection(
				:adapter => DB_ADAPTER,
				:database => db,
			)
			self.retrieve_connection
    
    end
  
  end

  class Run < DBConnection
	self.primary_key = "id"
	has_many :samples, :dependent => :destroy
  end
  
  class Sample < DBConnection
	self.primary_key = "id"
	has_many :pangolins, dependent: :destroy
	belongs_to :run

	def get_latest_pango_call
		self.pangolins.sort_by{|p| p.id }[-1]
	end

	def to_fasta
		answer = []
		answer << ">#{self.sample_id}"
		string = Zlib.inflate(self.sequence).split("\n")[1..-1].join

		while string.length > 80
			seq = string.slice!(0..79)
			answer << seq
		end
		answer << seq
		return answer.join("\n")
	end
  end

  class Pangolin < DBConnection
	self.primary_key = "id"
	belongs_to :sample
  end	

end
  
