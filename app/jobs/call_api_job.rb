require 'Product'

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
    @total = 0
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

        responses_cash = buybackapi_call_test(isbn_array) # call to buyback
                
        p "================================================" + items.length.to_s
        ten_prod_arr.length.times.map { |j|

          p "********************************************************************************"
          p "ten or twenty products========" + ten_prod_arr[j]
          if !items[j].nil?
            p "Amazon Resource=========" + items[j]['ASIN']
            next unless ten_prod_arr[j] == items[j]['ASIN']
          else
            next
          end

          product = Product.new 
          if !responses_cash[j].nil?
            # p "not nil" + responses_cash[j]
            p "not nil"

            begin
              response_buyback = JSON.parse(responses_cash[j]) unless responses_cash[j].nil?
            rescue Exception => e
              next              
            end

            # from the buyback
            if response_buyback["top_offer"].nil?
              product.cash       = 0.00
              product.top_vendor = ''
            else
              product.cash       = response_buyback["top_offer"]["price"] > 0.00 ? response_buyback["top_offer"]["price"] / 100.00 : 0.00
              product.top_vendor = ''
              product.top_vendor = response_buyback["asin"] if product.cash > 0
            end
            
            # from the AMZ PAAPI
            resource_url = items[j]['DetailPageURL']  
            sales_rank   = items[j]['SalesRank'].nil? ? 'No Rank' : items[j]['SalesRank']
            
            p 'resource_url' + resource_url
            # TradeIn
            if items[j]['ItemAttributes'].has_key? "TradeInValue"
              tradein_string = items[j]['ItemAttributes']['TradeInValue']['Amount']
              trade_in       = tradein_string.to_f / 100.00

            else
              trade_in = 0.00 
            end

          else
            
            p "mil"
            product.cash       = 0.00
            product.top_vendor = ""
            resource_url       = ""
            sales_rank         = "No Rank"
            trade_in = 0.00

          end
            
          p "inventory = " + data_hash[index - i + j + 1]['asin1'].to_s

          # from the inventory file
          product.msku  = data_hash[index -  i + j + 1]['sellerSku']
          product.name  = data_hash[index - i + j + 1]['item-name']
          product.price = data_hash[index - i +j + 1]['price']

          # DataTime Parse error handle
          begin
            days = (Time.now - DateTime.parse(data_hash[index -  i + j + 1]['opendate'])) / (3600 * 24)
            p "open date *********************************============" + data_hash[index -  i + j + 1]['opendate'] 
            p "days *********************************============" + days.to_s
          rescue Exception => e
            next
          end

          product.days  = days.ceil

          if days > 180 
            product.ltsf = "true"
          elsif days > 150
            product.ltsf = "soon"
          else
            product.ltsf = "false"
          end
          p "product ltsf *********************************============" + product.ltsf
          product.tradeinurl = resource_url
          product.rank       = sales_rank
          product.tradein    = trade_in

          total_profit = trade_in > product.cash ? trade_in : product.cash          
          
          @buyback_total     += product.cash
          @tradein_total     += product.tradein
          @total += total_profit
          @profit = @total * 0.08

          p product.cash
          p 'top_vendor' + product.top_vendor

          # add product to the result data if buyback or tradein value
          if product.cash > 0 || product.tradein != 0
            products << product
          else
          end
        }

        @percent = (index + 1) * 100 / data_hash.length 
        @progress_bar.update_attributes!({
                                          buyback: @buyback_total.round(2), 
                                          tradein: @tradein_total.round(2),
                                          total: @total,
                                          profit: @profit.round(2),
                                          percent: @percent
                                        })  
        i = 0
      else
        # puts i
      end
    }
    # save to public/result/#{filename}
    File.open("#{Rails.root}/public/result/#{filename}", "w") do |file|
      file.write(products.to_json)
    end
  end

  private

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

  def paapi_call(ten_prod_arr)
   
    # make 10 asin concatenate
    asin_length = ten_prod_arr.length

    if asin_length > 10 

      asins_1 = ten_prod_arr[0..9].join(',')
      asins_2 = ten_prod_arr[10..-1].join(',')

    else

      asins_1 = ten_prod_arr.join(',')
      asins_2 = ''

    end
    request = Vacuum.new
    query = {
      'ItemLookup.1.ItemId': asins_1, # asins
      'ItemLookup.Shared.ResponseGroup': 'ItemAttributes, SalesRank', # response groups
      'ItemLookup.Shared.IdType': 'ASIN',
      'ItemLookup.2.ItemId': asins_2  # asins
    }

    batches = nil

    until batches
      credentials = Redis.current.zrevrange("credentials", 0, -1)
      key = credentials.pop
      p key
      begin
        request.configure(JSON.parse(key))
        Redis.current.zadd("credentials", Time.now.to_i, key)
        response = request.item_lookup(query: query)
        batches = response.dig('ItemLookupResponse', 'Items')
      rescue Excon::Error::ServiceUnavailable, Excon::Error::Socket
        nil
      end
    end

    return batches
  end

end
