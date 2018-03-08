class ResultController < ApplicationController
	
	before_action :set_filename, :only => [:show, :renderjson] 

	def show
		file          = File.read('public/result/' + @file_name )
		data_hash     = JSON.parse(file)
		@progress_bar = Progressbar.find_by(taskname: @file_name)
	end	


	def renderjson
		file         = File.read('public/result/' + @file_name)
		data_hash    = JSON.parse(file)
		total_length = data_hash.length
		render json: {'aaData'=>data_hash, "iTotalRecords": total_length, "iTotalDisplayRecords": total_length}
	end

	
	private 

		def set_filename
			@file_name = params[:filename]
		end

end
