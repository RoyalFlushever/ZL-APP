class Inventory < ApplicationRecord
	def self.import(file)
		CSV.foreach( file.path, header: true ) do |row|
			# Invetory.create! row.to_hash
		end
	end
end
