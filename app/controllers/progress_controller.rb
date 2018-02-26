class ProgressController < ApplicationController
	
	@progress_bar		

	# initialize
	def initialize
		@progress_bar = Progressbar.new
	end

	# showing progress, here search product advertising API, bookfinder API
	def index
		
	end

	# progress endpoint
	# GET start
	# GET start.json
	def start
		filename = params[:filename]

		# 10.times do |i|
		# 	sleep(1)
		# end
		DemoWorker.perform_later(@progress_bar)
		render json: @progress_bar
	end

end
