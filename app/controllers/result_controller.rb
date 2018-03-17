class ResultController < ApplicationController
	protect_from_forgery :except => :download
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

	def download
		data_table = params[:row]
		p "--------------------------#{JSON.parse(data_table)[0]}"
		rows = JSON.parse(data_table)
		attributes = %w{ cash top_vendor msku product-name price days ltsf tradeinurl rank tradein }
		attributes = %w{ msku product-name rank days ltsf price tradein tradeinurl cash }
		order = [2, 3, 8, 5, 6, 4, 9, 7, 0, 1]

    file = CSV.generate(headers: true) do |csv|
      csv << attributes
      rows.each { |row|
      	p "--------------------------#{row.values}"
      	csv_row = order.map { |x| row.values[x]}
      	csv << csv_row[0..-2]
      }
    end

    send_data file, :type => "text/csv", :disposition => "attachment", :filename => "#{params[:filename]}.csv"
  end

  private 

	  def set_filename
	  	@file_name = params[:filename]
	  end

end
