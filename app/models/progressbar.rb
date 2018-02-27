class Progressbar < ApplicationRecord

	validates_numericality_of :percent,
		greater_than_or_equal_to: 0,
		less_than_or_equal_to: 100
	
	def self.init filename
		t = Progressbar.new
		t.percent = 0
		t.message = 'Calculating Instant Profit'
		t.status = 1
		t.tradein = 0
		t.buyback = 0
		t.profit = 0
		t.taskname = filename
		t.save
	end
end
