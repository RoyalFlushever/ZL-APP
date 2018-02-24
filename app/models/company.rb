class Company < ApplicationRecord
	def self.import_from_csv (file)
		csv = CSV.parse(file.path,  :headers => true, :encoding => Encoding::ISO_8859_1)
		
		csv.each do | row |
			# puts row.to_hash
			t = Company.new
			t.name = row['name'] 
      t.manager = row['manager']
      t.status = row['status']
      t.terms = row['terms']
      t.save
    end
	end
end
