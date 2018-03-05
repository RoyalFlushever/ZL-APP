class ResultController < ApplicationController
	def show
		file = File.read('public/result/' + 'table_test.json' )
    data_hash = JSON.parse(file)
	end	

	def renderjson
		file = File.read('public/result/' + 'table_test.json' )
    data_hash = JSON.parse(file)
    total = data_hash.length
    render json: {'aaData'=>data_hash,  "iTotalRecords": total,"iTotalDisplayRecords": total}
	end


end
