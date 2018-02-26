class IndexController < ApplicationController
	def index
		
	end

	def create
		filename = params[:filename]
		CallApiJob.perform_later(filename)
	end
end
