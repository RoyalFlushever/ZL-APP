class ProgressController < ApplicationController

	# showing progress, here search product advertising API, bookfinder API
	def index
		
	end

	# progress endpoint
	# GET start
	# GET start.json
	def start
		@progress_bar = {
			percent: 0,
			message: 'Calculating Instant profits: Starting',
			tradeInValue: 0,
			buyBackValue: 0
		}

		10.times do |i|
			sleep(1)
		end
		
		render json: @progress_bar
	end
end
