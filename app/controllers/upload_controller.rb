require 'csv'

class UploadController < ApplicationController
	def index
		
	end

	def import
		if params[:file].blank? || params[:file].path.empty?
      flash[:error] = "Warning! You must select File first."
      redirect_to upload_path
      return
    else
			file_name = Inventory.import_from_csv(params[:file])
			redirect_to start_path, file_name: file_name
		end
	end

	def show
		
	end
end
