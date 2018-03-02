require 'csv'

class UploadController < ApplicationController
	
	# GET /upload 
	def index
		
	end

	# POST /import_inventory
	def import

		if params[:file].blank? || params[:file].path.empty?

      flash[:error] = "Warning! You must select File first."
      redirect_to upload_path
      return

    else

			file_name = Inventory.import_from_csv(params[:file])
			Progressbar.init(file_name)

			respond_to do |format|
		    result = { redirect_url: start_url, filename: file_name }
		    format.json  { render :json => result } # don't do msg.to_json
		  end

		end

	end

	# GET /show

end
