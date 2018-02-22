require 'csv'

class UploadController < ApplicationController
	def index
		
	end

	def import
		Inventory.import(params[:file])
		redirect_to show_path, notice: "Inventory Imported Successfully"
	end

	def show
		
	end
end
