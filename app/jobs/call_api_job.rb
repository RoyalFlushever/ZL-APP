require 'Product'
require 'bookland'

class CallApiJob < ActiveJob::Base 
  queue_as :default

  def perform(filename)
  	@progress_bar = Progressbar.find_by(taskname: filename)

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
  	# create result product array
  	products = [] # :msku, :name, :price, :days, :ltsf, :price, :tradein, :cash

    data_hash.length.times.map { |index|  
    	
    	# get every 10 items for a request.
    	ten_prod_arr = [] if i == 0 # the begining of the 10 items per request
    	ten_prod_arr << data_hash[index]["asin1"]
			i += 1
			# puts @percent
			
			if i == 20 or data_hash[index].equal? data_hash.last # every 20 calls
				
        valid_asins    = asin_validation_test ten_prod_arr
        response_amz   = paapi_call valid_asins                        # call to amazon

        if response_amz.is_a?(Array) # if 20 items
          items = response_amz[0]['Item'] + response_amz[1]['Item'] # all 20 items response in an Array
        else 
          items = response_amz['Item'] # last items in an Array
        end

        # get ISBNs for BuyBack API
        isbn_array = []
        items.each do |item|
          asin = item['ASIN']
          if !item['ItemAttributes']['ISBN'].nil?
            isbn = item['ItemAttributes']['ISBN']

          elsif !item['ItemAttributes']['EISBN'].nil?
            isbn = item['ItemAttributes']['EISBN']

          else
            isbn = ''
          end
          isbn_array << isbn
        end

        responses_cash = buybackapi_call_test isbn_array     # call to buyback
                
        p items.length
        ten_prod_arr.length.times.map { | j |

          product = Product.new 
          if !responses_cash[j].nil?
            p "not nil"
            response_buyback = JSON.parse(responses_cash[j]) unless responses_cash[j].nil?
            # from the buyback
            if response_buyback["top_offer"].nil?
              product.cash       = 0
              product.top_vendor = ''
            else
              product.cash       = response_buyback["top_offer"]["price"] / 100.00
              product.top_vendor = response_buyback["top_offer"]["vendor_name"]
            end
            
            # from the AMZ PAAPI
            resource_url = items[j]['DetailPageURL']  
            sales_rank   = items[j]['SalesRank'].nil? ? 'No Rank' : items[j]['SalesRank']
            
            p 'resource_url' + resource_url
            # TradeIn
            if items[j]['ItemAttributes'].has_key? "TradeInValue"
              tradein_string = items[j]['ItemAttributes']['TradeInValue']['Amount']
              trade_in       = tradein_string.to_f / 100

            else
              trade_in = 0 
            end

          else
            
            p "mil"
            product.cash       = 0
            product.top_vendor = ""
            resource_url       = ""
            sales_rank         = "No Rank"
            trade_in = 0

          end
            
          p "inventory = " + data_hash[index - 20 + j + 1]['asin1'].to_s

          # from the inventory file
          product.msku  = data_hash[index - 20 + j + 1]['sellerSku']
          product.name  = data_hash[index -20 + j + 1]['item-name']
          product.price = data_hash[index -20 +j + 1]['price']
          days          = (Time.now - DateTime.parse(data_hash[index - 20 + j + 1]['opendate'])) / (3600 * 24)
          product.days  = days.ceil
          product.ltsf  = days > 90 ? true : false

          product.tradeinurl = resource_url
          product.rank       = sales_rank
          product.tradein    = trade_in
          
          @buyback_total     += product.cash
          @tradein_total     += product.tradein

          # add product to the result data if buyback or tradein value
          if product.cash != 0
            products << product
          else
          end
        }

        @percent = (index + 1) * 100 / data_hash.length 
        @progress_bar.update_attributes!({
                                          buyback: @buyback_total, 
                                          tradein: @tradein_total,
                                          percent: @percent
                                        })  
        i = 0
        sleep(10)
      else  
        # puts i
      end
    }
    # save to public/result/#{filename}
		File.open("public/result/#{filename}", "w") do |file|
      file.write(products.to_json)
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
  end

  # asin validation: solve 10 digits issue
	def asin_validation_test ten_asins
		valid_asins = []
		valid_asin_regex = /\A[0-9,A-Z]{10}\z/

		ten_asins.each do |asin|
			# validate if it's ASIN or ISBN
			# if ASIN nothing
			# ISBN, test 10 digits (less than 10)
			# if not 10, append 0 in the front of ISBN
			if asin =~ /\A[0-9,A-Z]{10}\z/
				valid_asins << asin
			else
				zeros = 10 - asin.length
        zeros.times {
          asin.insert(0,'0')
        }
				valid_asins << asin
			end
		end

		return valid_asins
	end

	def paapi_call ten_prod_arr
		# use vacuum gem
    request = Vacuum.new
		
    request.configure(
      aws_access_key_id: 'AKIAIOXYKUVGX7Q44KXQ',
      aws_secret_access_key: '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',
      associate_tag: 'bharathvasan9-20'
    )

		# make 10 asin concatenate
    asin_length = ten_prod_arr.length
    if asin_length > 10 
      asins_1 = ten_prod_arr[0..9].join(',')
      asins_2 = ten_prod_arr[10..-1].join(',')
    else
      asins_1 = ten_prod_arr.join(',')
      asins_2 = ''
    end

    query = {
    'ItemLookup.1.ItemId': asins_1,# asins
    'ItemLookup.Shared.ResponseGroup': 'ItemAttributes, SalesRank', # response groups
    'ItemLookup.Shared.IdType': 'ISBN',
    'ItemLookup.Shared.SearchIndex': 'All',
    'ItemLookup.2.ItemId': asins_2# asins
    }

		begin
			response = request.item_lookup(query: query)
			puts response.status
			# Return up to 20 offers.
      # [{10items}, {10items}] 
			batches = response.dig('ItemLookupResponse', 'Items')
		rescue Excon::Error::ServiceUnavailable
      nil
    end
	end
end
