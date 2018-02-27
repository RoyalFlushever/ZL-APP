require 'Product'

class CallApiJob < ActiveJob::Base 

  queue_as :default

  def perform(filename)
  	@progress_bar = Progressbar.find_by(taskname: filename)
    # 1.times do |i|
    # 	sleep(1)
    #   @progress_bar.update_attributes!(percent: i * 10)
    # end

    # @progress_bar attr
    @percent = 0
    @message = 'Calculating'
    @status = 1
    @tradein_total = 0
    @buyback_total = 0
    @profit = 0
 
    # open inventory json file
    file = File.read('public/inventory/' + filename )
    data_hash = JSON.parse(file)
  	i = 0
    ten_prod_arr = []
  	# create result product json file
  	

    data_hash.each do | listing_item |
    	@percent += 1
    	sleep(3.0/4.0)
    	product = Product.new

    	# from the inventory file
    	product.msku = listing_item['sellerSku']
			product.name = listing_item['name']
			product.price = listing_item['price']
			product.days = (Time.now - DateTime.parse(listing_item['opendate'])) / (3600 * 24)
    	# get every 10 items for a request.
    	ten_prod_arr = [] if i == 0 # the begining of the 10 items per request
    	ten_prod_arr << listing_item["asin1"]
			i += 1
			
			if i == 10
				i = 0
				paapi_call_test ten_prod_arr
				buybackapi_call_test ten_prod_arr
			
			elsif listing_item.equal? data_hash.last
				# detect the last element
				paapi_call_test ten_prod_arr 
				
				# buyback value API
				# need ISBN validation
				# typheous 10 buyback value API at a time
				buybackapi_call_test ten_prod_arr
			else	
				puts i
			end	
		end
  end

  def buybackapi_call_test ten_prod_arr
  	buyback_base_url = "http://34.210.169.97/buyback/temp?asins=" 
  	
  	hydra = Typhoeus::Hydra.new

  	requests = ten_prod_arr.length.times.map { |i|
		  request = Typhoeus::Request.new(buyback_base_url + ten_prod_arr[i])
		  hydra.queue(request)
		  request
		}
		hydra.run # this is a blocking call that returns once all requests are complete

		responses = requests.map { |request|
		  request.response.body
		}

		responses.each do |response|
			puts response
		end
  end

  def buybackapi_call
	  
  end

	def paapi_call_test ten_prod_arr
		asin_concact = ten_prod_arr.join(",")
		puts asin_concact
	end

	def paapi_call ten_prod_arr
		# use vacuum gem
    request = Vacuum.new
    request.configure(
		  aws_access_key_id: 'AKIAIM5CZH6OERDFHP3Q',
		  aws_secret_access_key: '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',
		  associate_tag: 'vintagevideog-20'
		)

		# make 10 asin concatenate
		asin_concact = ten_prod_arr.join(",")

		query = {
			'ItemId' => asin_concact,
			'SearchIndex' => 'All',
			'ResponseGroup' => 'ItemAttributes, SalesRank',
			'IdType' => 'ISBN'
		}

		begin
			response = request.item_lookup(query: query, persistent: true)
			# Return up to 20 offers in an array.
			batches = res.dig('ItemLookupResponse', 'Items')
			puts batches
			# case response.status
			# 	when 200
			# 		hashed_products = response.to_h
			# 		if !hashed_products["ItemLookupResponse"].has_key? "Errors"
			# 			item_hash = hashed_products["ItemLookupResponse"]["Items"]["Item"]

			# 			# SalesRank
			# 			# puts "SalesRank: " +  item_hash['SalesRank']

			# 			# TradeIn
			# 			if item_hash['ItemAttributes'].has_key? "TradeInValue"
			# 				tradein_string = item_hash['ItemAttributes']['TradeInValue']['Amount']
			# 				trade_in = tradein_string.to_f / 100
			# 			else
			# 				trade_in = 0							
			# 			end
			# 			puts trade_in
			# 		else
			# 			puts hashed_products["ItemLookupResponse"]["Errors"]["Message"]
			# 		end
					
			# 	when 403
			# 		puts "These errors indicate an issue with the request. A 403 indicates the request was not authenticated correctly."
			# 	when 503
			# 		puts "A 503 error means that you are submitting requests too quickly and your requests are being throttled"
			# end	
		rescue => e
			puts e.inspect
    end
	end
end
