# DataStructure for Progressbar
# attrs: 
# 	percent: processed asins / total inventory asins * 100
# 	status: 
# 					1: progressing - notification: Calculating Instant profits
# 					2: finished
# 	tradein: total instant tradein value: e.g. 1056
# 	buyback: total instant buyback value: e.g. 755
# 	profit:  For mutual value differecnce in total inventories: e.g. 158.4

class Progressbar
	
	attr_accessor :percent, :status, :tradein, :buyback, :profit
	
	def initialize()
    @percent = 0
    @status = "Calculating Instant profits"
    @tradein = 0
    @buyback = 0
    @profit = 0
	end
	
end