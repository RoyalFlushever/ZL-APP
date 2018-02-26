class Progressbar < ApplicationRecord
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
