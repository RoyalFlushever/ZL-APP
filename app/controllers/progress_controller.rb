class ProgressController < ApplicationController
	
	# showing progress, here search product advertising API, bookfinder API
	def index
		
	end

	# progress endpoint
	# GET start
	# GET start.json
	def start
		filename = params[:filename]
		@progress_bar = Progressbar.find_by(taskname: filename)
		render json: @progress_bar
	end

end
