#DB_ADAPTER = "sqlite3"
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
  
  class Sample < DBConnection
	self.primary_key = "id"
	has_many :pangolins, dependent: :destroy
  end

  class Pangolin < DBConnection
	self.primary_key = id
	belongs_to :sample, foreign_key: "sample_id"
  end	

end
  
