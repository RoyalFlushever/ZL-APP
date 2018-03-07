require 'Product'
require 'bookland'

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
  	# create result product array
  	products = [] # :msku, :name, :price, :days, :ltsf, :price, :tradein, :cash
  	# valid_ten_asins = asin_validation_test
  	# p valid_ten_asins
		# items = paapi_call_test
		# items.each do |item|
		# 	product = Product.new
		# 	asin = item['ASIN']
		# 	resource_url = item['DetailPageURL']
		# 	sales_rank = item['SalesRank'].nil? ? 'no rank' : item['SalesRank']

		# 	if !item['ItemAttributes']['ISBN'].nil?
		# 		isbn = item['ItemAttributes']['ISBN']

		# 	elsif !item['ItemAttributes']['EISBN'].nil?
		# 		isbn = item['ItemAttributes']['EISBN']

		# 	else
		# 		isbn = ''

		# 	end
			
		# 	# TradeIn
		# 	if item['ItemAttributes'].has_key? "TradeInValue"
		# 		tradein_string = item['ItemAttributes']['TradeInValue']['Amount']
		# 		trade_in = tradein_string.to_f / 100
			
  #     else
		# 		trade_in = 0	
			
  #     end

		# 	product.tradeinurl = resource_url
		# 	product.rank = sales_rank
		# 	product.tradein = trade_in

		# 	products << product
		# end

		# File.open("public/result/#{filename}", "w") do |file|
  #     file.write(products.to_json)
  #   end

    data_hash.length.times.map { |index|  
    	
    	# get every 10 items for a request.
    	ten_prod_arr = [] if i == 0 # the begining of the 10 items per request
    	ten_prod_arr << data_hash[index]["asin1"]
			i += 1
			# puts @percent
			
			if i == 20 or data_hash[index].equal? data_hash.last # every 10 calls
				p i
				i = 0
        valid_asins = asin_validation_test ten_prod_arr
				# paapi_call_test ten_prod_arr
        paapi_call valid_asins
				sleep(10)
				responses_cash = buybackapi_call_test ten_prod_arr
								
				ten_prod_arr.length.times.map { | i |
					# puts data_hash[index - ten_prod_arr.length + i + 1]['asin1']
					response_buyback = JSON.parse(responses_cash[i])
					# puts response_buyback["asin"]
					product = Product.new	
					# from the inventory file
		    	product.msku = data_hash[index - 20 + i + 1]['sellerSku']
					product.name = data_hash[index -20 + i + 1]['item-name']
					product.price = data_hash[index -20 +i + 1]['price']
					days = (Time.now - DateTime.parse(data_hash[index - 20 + i + 1]['opendate'])) / (3600 * 24)
					product.days = days.ceil
					product.ltsf = days > 90 ? true : false
					if response_buyback["top_offer"].nil?
						product.cash = 0
						product.top_vendor = ''
					else
						product.cash = response_buyback["top_offer"]["price"] / 100.00
						product.top_vendor = response_buyback["top_offer"]["vendor_name"]
					end
					@buyback_total += product.cash
					# add product to the result data if buyback or tradein value
					if product.cash != 0
						products << product
					else
					end
				}

				@percent = (index + 1) * 100 / data_hash.length 
				@progress_bar.update_attributes!({
																					buyback: @buyback_total, 
																					percent: @percent
																				})	
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

  def buybackapi_call
	  
  end

	def paapi_call_test
		# asin_concact = ten_prod_arr.join(",")
		# request = Vacuum.new
		# begin
		# 	response = request.item_lookup(query: query)
		# 	# Return up to 20 offers in an array.
		# 	batches = res.dig('ItemLookupResponse', 'Items')
		# 	batches = response.dig('ItemLookupResponse', 'Items')
		# end
		batches = {
    "Request" =>
    {
        "IsValid" => "True", "ItemLookupRequest" =>
        {
            "IdType" => "ISBN", "ItemId" => ["898753740", "932963099", "985751665", "1453596216", "158648642X", "1626390851", "1908968044", "B0006Y8CEG", "B0000CKZ0S"], "ResponseGroup" => ["ItemAttributes", "SalesRank"], "SearchIndex" => "All", "VariationPage" => "All"
        }, "Errors" =>
        {
            "Error" => [
            {
                "Code" => "AWS.InvalidParameterValue",
                "Message" => "898753740 is not a valid value for ItemId. Please change this value and retry your request."
            },
            {
                "Code" => "AWS.InvalidParameterValue",
                "Message" => "932963099 is not a valid value for ItemId. Please change this value and retry your request."
            },
            {
                "Code" => "AWS.InvalidParameterValue",
                "Message" => "985751665 is not a valid value for ItemId. Please change this value and retry your request."
            }]
        }
    }, 
    "Item" => [
    {
        "ASIN" => "1453596216",
        "DetailPageURL" => "https://www.amazon.com/Poems-Comfort-Occasional-Meaningful-Satisfying/dp/1453596216?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=165953&creativeASIN=1453596216",
        "ItemLinks" =>
        {
            "ItemLink" => [
            {
                "Description" => "Technical Details",
                "URL" => "https://www.amazon.com/Poems-Comfort-Occasional-Meaningful-Satisfying/dp/tech-data/1453596216?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1453596216"
            },
            {
                "Description" => "Add To Baby Registry",
                "URL" => "https://www.amazon.com/gp/registry/baby/add-item.html?asin.0=1453596216&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1453596216"
            },
            {
                "Description" => "Add To Wedding Registry",
                "URL" => "https://www.amazon.com/gp/registry/wedding/add-item.html?asin.0=1453596216&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1453596216"
            },
            {
                "Description" => "Add To Wishlist",
                "URL" => "https://www.amazon.com/gp/registry/wishlist/add-item.html?asin.0=1453596216&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1453596216"
            },
            {
                "Description" => "Tell A Friend",
                "URL" => "https://www.amazon.com/gp/pdp/taf/1453596216?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1453596216"
            },
            {
                "Description" => "All Customer Reviews",
                "URL" => "https://www.amazon.com/review/product/1453596216?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1453596216"
            },
            {
                "Description" => "All Offers",
                "URL" => "https://www.amazon.com/gp/offer-listing/1453596216?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1453596216"
            }]
        },
        "SalesRank" => "13709985",
        "ItemAttributes" =>
        {
            "Author" => "Wanda Alexander Davis", "Binding" => "Paperback", "Brand" => "Wanda Alexander Davis Davis Wanda Alexander", "EAN" => "9781453596210", "EANList" =>
            {
                "EANListElement" => "9781453596210"
            }, "Feature" => "Poems for Comfort", "ISBN" => "1453596216", "ItemDimensions" =>
            {
                "Height" =>
                {
                    "__content__" => "900", "Units" => "hundredths-inches"
                }, "Length" =>
                {
                    "__content__" => "600", "Units" => "hundredths-inches"
                }, "Weight" =>
                {
                    "__content__" => "50", "Units" => "Hundredths Pounds"
                }, "Width" =>
                {
                    "__content__" => "33", "Units" => "hundredths-inches"
                }
            }, "Label" => "Xlibris, Corp.", "Languages" =>
            {
                "Language" => [
                {
                    "Name" => "English",
                    "Type" => "Published"
                },
                {
                    "Name" => "English",
                    "Type" => "Original Language"
                },
                {
                    "Name" => "English",
                    "Type" => "Unknown"
                }]
            }, "ListPrice" =>
            {
                "Amount" => "1999", "CurrencyCode" => "USD", "FormattedPrice" => "$19.99"
            }, "Manufacturer" => "Xlibris, Corp.", "NumberOfItems" => "1", "NumberOfPages" => "146", "PackageDimensions" =>
            {
                "Height" =>
                {
                    "__content__" => "100", "Units" => "hundredths-inches"
                }, "Length" =>
                {
                    "__content__" => "890", "Units" => "hundredths-inches"
                }, "Weight" =>
                {
                    "__content__" => "55", "Units" => "Hundredths Pounds"
                }, "Width" =>
                {
                    "__content__" => "590", "Units" => "hundredths-inches"
                }
            }, "ProductGroup" => "Book", "ProductTypeName" => "ABIS_BOOK", "PublicationDate" => "2011-03-01", "Publisher" => "Xlibris, Corp.", "Studio" => "Xlibris, Corp.", "Title" => "Poems for Comfort: Occasional, Effective, Meaningful, Satisfying"
        }
    },
    {
        "ASIN" => "B0793TZJ7Z",
        "DetailPageURL" => "https://www.amazon.com/Poems-Comfort-Occasional-Meaningful-Satisfying-ebook/dp/B0793TZJ7Z?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0793TZJ7Z",
        "ItemLinks" =>
        {
            "ItemLink" => [
            {
                "Description" => "Technical Details",
                "URL" => "https://www.amazon.com/Poems-Comfort-Occasional-Meaningful-Satisfying-ebook/dp/tech-data/B0793TZJ7Z?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0793TZJ7Z"
            },
            {
                "Description" => "Add To Baby Registry",
                "URL" => "https://www.amazon.com/gp/registry/baby/add-item.html?asin.0=B0793TZJ7Z&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0793TZJ7Z"
            },
            {
                "Description" => "Add To Wedding Registry",
                "URL" => "https://www.amazon.com/gp/registry/wedding/add-item.html?asin.0=B0793TZJ7Z&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0793TZJ7Z"
            },
            {
                "Description" => "Add To Wishlist",
                "URL" => "https://www.amazon.com/gp/registry/wishlist/add-item.html?asin.0=B0793TZJ7Z&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0793TZJ7Z"
            },
            {
                "Description" => "Tell A Friend",
                "URL" => "https://www.amazon.com/gp/pdp/taf/B0793TZJ7Z?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0793TZJ7Z"
            },
            {
                "Description" => "All Customer Reviews",
                "URL" => "https://www.amazon.com/review/product/B0793TZJ7Z?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0793TZJ7Z"
            },
            {
                "Description" => "All Offers",
                "URL" => "https://www.amazon.com/gp/offer-listing/B0793TZJ7Z?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0793TZJ7Z"
            }]
        },
        "ItemAttributes" =>
        {
            "Author" => "Wanda Alexander Davis", "Binding" => "Kindle Edition", "EISBN" => "9781499066807", "Format" => "Kindle eBook", "Label" => "Xlibris US", "Languages" =>
            {
                "Language" =>
                {
                    "Name" => "English", "Type" => "Published"
                }
            }, "Manufacturer" => "Xlibris US", "NumberOfPages" => "146", "ProductGroup" => "eBooks", "ProductTypeName" => "ABIS_EBOOKS", "PublicationDate" => "2011-03-01", "Publisher" => "Xlibris US", "ReleaseDate" => "2011-03-01", "Studio" => "Xlibris US", "Title" => "Poems for Comfort: Occasional, Effective, Meaningful, Satisfying"
        }
    },
    {
        "ASIN" => "158648642X",
        "DetailPageURL" => "https://www.amazon.com/Billionaire-Who-Wasnt-Secretly-Fortune/dp/158648642X?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=165953&creativeASIN=158648642X",
        "ItemLinks" =>
        {
            "ItemLink" => [
            {
                "Description" => "Technical Details",
                "URL" => "https://www.amazon.com/Billionaire-Who-Wasnt-Secretly-Fortune/dp/tech-data/158648642X?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=158648642X"
            },
            {
                "Description" => "Add To Baby Registry",
                "URL" => "https://www.amazon.com/gp/registry/baby/add-item.html?asin.0=158648642X&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=158648642X"
            },
            {
                "Description" => "Add To Wedding Registry",
                "URL" => "https://www.amazon.com/gp/registry/wedding/add-item.html?asin.0=158648642X&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=158648642X"
            },
            {
                "Description" => "Add To Wishlist",
                "URL" => "https://www.amazon.com/gp/registry/wishlist/add-item.html?asin.0=158648642X&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=158648642X"
            },
            {
                "Description" => "Tell A Friend",
                "URL" => "https://www.amazon.com/gp/pdp/taf/158648642X?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=158648642X"
            },
            {
                "Description" => "All Customer Reviews",
                "URL" => "https://www.amazon.com/review/product/158648642X?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=158648642X"
            },
            {
                "Description" => "All Offers",
                "URL" => "https://www.amazon.com/gp/offer-listing/158648642X?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=158648642X"
            }]
        },
        "SalesRank" => "1610707",
        "ItemAttributes" =>
        {
            "Author" => "Conor O'Clery", "Binding" => "Paperback", "EAN" => "`", "EANList" =>
            {
                "EANListElement" => "9781586486426"
            }, "ISBN" => "158648642X", "ItemDimensions" =>
            {
                "Height" =>
                {
                    "__content__" => "830", "Units" => "hundredths-inches"
                }, "Length" =>
                {
                    "__content__" => "550", "Units" => "hundredths-inches"
                }, "Weight" =>
                {
                    "__content__" => "80", "Units" => "Hundredths Pounds"
                }, "Width" =>
                {
                    "__content__" => "83", "Units" => "hundredths-inches"
                }
            }, "Label" => "PublicAffairs", "Languages" =>
            {
                "Language" => [
                {
                    "Name" => "English",
                    "Type" => "Published"
                },
                {
                    "Name" => "English",
                    "Type" => "Original Language"
                },
                {
                    "Name" => "English",
                    "Type" => "Unknown"
                }]
            }, "ListPrice" =>
            {
                "Amount" => "1595", "CurrencyCode" => "USD", "FormattedPrice" => "$15.95"
            }, "Manufacturer" => "PublicAffairs", "NumberOfItems" => "1", "NumberOfPages" => "368", "PackageDimensions" =>
            {
                "Height" =>
                {
                    "__content__" => "110", "Units" => "hundredths-inches"
                }, "Length" =>
                {
                    "__content__" => "820", "Units" => "hundredths-inches"
                }, "Weight" =>
                {
                    "__content__" => "75", "Units" => "Hundredths Pounds"
                }, "Width" =>
                {
                    "__content__" => "550", "Units" => "hundredths-inches"
                }
            }, "PackageQuantity" => "1", "ProductGroup" => "Book", "ProductTypeName" => "ABIS_BOOK", "PublicationDate" => "2008-09-23", "Publisher" => "PublicAffairs", "ReleaseDate" => "2008-09-22", "Studio" => "PublicAffairs", "Title" => "The Billionaire Who Wasn't: How Chuck Feeney Secretly Made and Gave Away a Fortune"
        }
    },
    {
        "ASIN" => "B0023RT06S",
        "DetailPageURL" => "https://www.amazon.com/Billionaire-Who-Wasnt-Secretly-Fortune/dp/B0023RT06S?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0023RT06S",
        "ItemLinks" =>
        {
            "ItemLink" => [
            {
                "Description" => "Technical Details",
                "URL" => "https://www.amazon.com/Billionaire-Who-Wasnt-Secretly-Fortune/dp/tech-data/B0023RT06S?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0023RT06S"
            },
            {
                "Description" => "Add To Baby Registry",
                "URL" => "https://www.amazon.com/gp/registry/baby/add-item.html?asin.0=B0023RT06S&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0023RT06S"
            },
            {
                "Description" => "Add To Wedding Registry",
                "URL" => "https://www.amazon.com/gp/registry/wedding/add-item.html?asin.0=B0023RT06S&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0023RT06S"
            },
            {
                "Description" => "Add To Wishlist",
                "URL" => "https://www.amazon.com/gp/registry/wishlist/add-item.html?asin.0=B0023RT06S&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0023RT06S"
            },
            {
                "Description" => "Tell A Friend",
                "URL" => "https://www.amazon.com/gp/pdp/taf/B0023RT06S?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0023RT06S"
            },
            {
                "Description" => "All Customer Reviews",
                "URL" => "https://www.amazon.com/review/product/B0023RT06S?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0023RT06S"
            },
            {
                "Description" => "All Offers",
                "URL" => "https://www.amazon.com/gp/offer-listing/B0023RT06S?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0023RT06S"
            }]
        },
        "SalesRank" => "6413459",
        "ItemAttributes" =>
        {
            "Author" => "Conor O'Clery", "Binding" => "Paperback", "EAN" => "9781586486426", "EANList" =>
            {
                "EANListElement" => "9781586486426"
            }, "Format" => "Bargain Price", "ISBN" => "158648642X", "ItemDimensions" =>
            {
                "Height" =>
                {
                    "__content__" => "100", "Units" => "hundredths-inches"
                }, "Length" =>
                {
                    "__content__" => "800", "Units" => "hundredths-inches"
                }, "Width" =>
                {
                    "__content__" => "540", "Units" => "hundredths-inches"
                }
            }, "Label" => "PublicAffairs", "Languages" =>
            {
                "Language" => [
                {
                    "Name" => "English",
                    "Type" => "Published"
                },
                {
                    "Name" => "English",
                    "Type" => "Unknown"
                }]
            }, "ListPrice" =>
            {
                "Amount" => "1595", "CurrencyCode" => "USD", "FormattedPrice" => "$15.95"
            }, "Manufacturer" => "PublicAffairs", "NumberOfItems" => "1", "NumberOfPages" => "368", "PackageDimensions" =>
            {
                "Height" =>
                {
                    "__content__" => "100", "Units" => "hundredths-inches"
                }, "Length" =>
                {
                    "__content__" => "810", "Units" => "hundredths-inches"
                }, "Weight" =>
                {
                    "__content__" => "80", "Units" => "Hundredths Pounds"
                }, "Width" =>
                {
                    "__content__" => "550", "Units" => "hundredths-inches"
                }
            }, "PackageQuantity" => "1", "ProductGroup" => "Book", "ProductTypeName" => "ABIS_BOOK", "PublicationDate" => "2008-09-22", "Publisher" => "PublicAffairs", "ReleaseDate" => "2008-09-22", "Studio" => "PublicAffairs", "Title" => "The Billionaire Who Wasn't: How Chuck Feeney Secretly Made and Gave Away a Fortune"
        }
    },
    {
        "ASIN" => "1626390851",
        "DetailPageURL" => "https://www.amazon.com/Tumbledown-Cari-Hunter/dp/1626390851?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=165953&creativeASIN=1626390851",
        "ItemLinks" =>
        {
            "ItemLink" => [
            {
                "Description" => "Technical Details",
                "URL" => "https://www.amazon.com/Tumbledown-Cari-Hunter/dp/tech-data/1626390851?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1626390851"
            },
            {
                "Description" => "Add To Baby Registry",
                "URL" => "https://www.amazon.com/gp/registry/baby/add-item.html?asin.0=1626390851&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1626390851"
            },
            {
                "Description" => "Add To Wedding Registry",
                "URL" => "https://www.amazon.com/gp/registry/wedding/add-item.html?asin.0=1626390851&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1626390851"
            },
            {
                "Description" => "Add To Wishlist",
                "URL" => "https://www.amazon.com/gp/registry/wishlist/add-item.html?asin.0=1626390851&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1626390851"
            },
            {
                "Description" => "Tell A Friend",
                "URL" => "https://www.amazon.com/gp/pdp/taf/1626390851?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1626390851"
            },
            {
                "Description" => "All Customer Reviews",
                "URL" => "https://www.amazon.com/review/product/1626390851?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1626390851"
            },
            {
                "Description" => "All Offers",
                "URL" => "https://www.amazon.com/gp/offer-listing/1626390851?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1626390851"
            }]
        },
        "SalesRank" => "1993621",
        "ItemAttributes" =>
        {
            "Author" => "Cari Hunter", "Binding" => "Paperback", "EAN" => "9781626390850", "EANList" =>
            {
                "EANListElement" => "9781626390850"
            }, "ISBN" => "1626390851", "ItemDimensions" =>
            {
                "Height" =>
                {
                    "__content__" => "840", "Units" => "hundredths-inches"
                }, "Length" =>
                {
                    "__content__" => "540", "Units" => "hundredths-inches"
                }, "Weight" =>
                {
                    "__content__" => "60", "Units" => "Hundredths Pounds"
                }, "Width" =>
                {
                    "__content__" => "80", "Units" => "hundredths-inches"
                }
            }, "Label" => "Bold Strokes Books", "Languages" =>
            {
                "Language" => [
                {
                    "Name" => "English",
                    "Type" => "Published"
                },
                {
                    "Name" => "English",
                    "Type" => "Original Language"
                },
                {
                    "Name" => "English",
                    "Type" => "Unknown"
                }]
            }, "ListPrice" =>
            {
                "Amount" => "1695", "CurrencyCode" => "USD", "FormattedPrice" => "$16.95"
            }, "Manufacturer" => "Bold Strokes Books", "NumberOfItems" => "1", "NumberOfPages" => "264", "PackageDimensions" =>
            {
                "Height" =>
                {
                    "__content__" => "80", "Units" => "hundredths-inches"
                }, "Length" =>
                {
                    "__content__" => "840", "Units" => "hundredths-inches"
                }, "Weight" =>
                {
                    "__content__" => "55", "Units" => "Hundredths Pounds"
                }, "Width" =>
                {
                    "__content__" => "550", "Units" => "hundredths-inches"
                }
            }, "PackageQuantity" => "1", "ProductGroup" => "Book", "ProductTypeName" => "ABIS_BOOK", "PublicationDate" => "2014-02-18", "Publisher" => "Bold Strokes Books", "Studio" => "Bold Strokes Books", "Title" => "Tumbledown"
        }
    },
    {
        "ASIN" => "1908968044",
        "DetailPageURL" => "https://www.amazon.com/French-Father-Alain-Elkann/dp/1908968044?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=165953&creativeASIN=1908968044",
        "ItemLinks" =>
        {
            "ItemLink" => [
            {
                "Description" => "Technical Details",
                "URL" => "https://www.amazon.com/French-Father-Alain-Elkann/dp/tech-data/1908968044?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1908968044"
            },
            {
                "Description" => "Add To Baby Registry",
                "URL" => "https://www.amazon.com/gp/registry/baby/add-item.html?asin.0=1908968044&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1908968044"
            },
            {
                "Description" => "Add To Wedding Registry",
                "URL" => "https://www.amazon.com/gp/registry/wedding/add-item.html?asin.0=1908968044&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1908968044"
            },
            {
                "Description" => "Add To Wishlist",
                "URL" => "https://www.amazon.com/gp/registry/wishlist/add-item.html?asin.0=1908968044&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1908968044"
            },
            {
                "Description" => "Tell A Friend",
                "URL" => "https://www.amazon.com/gp/pdp/taf/1908968044?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1908968044"
            },
            {
                "Description" => "All Customer Reviews",
                "URL" => "https://www.amazon.com/review/product/1908968044?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1908968044"
            },
            {
                "Description" => "All Offers",
                "URL" => "https://www.amazon.com/gp/offer-listing/1908968044?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=1908968044"
            }]
        },
        "SalesRank" => "6197189",
        "ItemAttributes" =>
        {
            "Author" => "Alain Elkann", "Binding" => "Paperback", "Brand" => "Brand: Pushkin Press", "Creator" =>
            {
                "__content__" => "Alastair McEwen", "Role" => "Translator"
            }, "EAN" => "9781908968043", "EANList" =>
            {
                "EANListElement" => "9781908968043"
            }, "Edition" => "Reprint", "Feature" => "Used Book in Good Condition", "ISBN" => "1908968044", "ItemDimensions" =>
            {
                "Height" =>
                {
                    "__content__" => "776", "Units" => "hundredths-inches"
                }, "Length" =>
                {
                    "__content__" => "510", "Units" => "hundredths-inches"
                }, "Weight" =>
                {
                    "__content__" => "29", "Units" => "Hundredths Pounds"
                }, "Width" =>
                {
                    "__content__" => "40", "Units" => "hundredths-inches"
                }
            }, "Label" => "Pushkin Press", "Languages" =>
            {
                "Language" => [
                {
                    "Name" => "English",
                    "Type" => "Published"
                },
                {
                    "Name" => "Italian",
                    "Type" => "Original Language"
                },
                {
                    "Name" => "English",
                    "Type" => "Unknown"
                }]
            }, "ListPrice" =>
            {
                "Amount" => "1595", "CurrencyCode" => "USD", "FormattedPrice" => "$15.95"
            }, "Manufacturer" => "Pushkin Press", "MPN" => "ill", "NumberOfItems" => "1", "NumberOfPages" => "128", "PackageDimensions" =>
            {
                "Height" =>
                {
                    "__content__" => "55", "Units" => "hundredths-inches"
                }, "Length" =>
                {
                    "__content__" => "764", "Units" => "hundredths-inches"
                }, "Weight" =>
                {
                    "__content__" => "31", "Units" => "Hundredths Pounds"
                }, "Width" =>
                {
                    "__content__" => "504", "Units" => "hundredths-inches"
                }
            }, "PartNumber" => "ill", "ProductGroup" => "Book", "ProductTypeName" => "ABIS_BOOK", "PublicationDate" => "2013-02-05", "Publisher" => "Pushkin Press", "ReleaseDate" => "2013-02-05", "Studio" => "Pushkin Press", "Title" => "The French Father"
        }
    },
    {
        "ASIN" => "B0006Y8CEG",
        "DetailPageURL" => "https://www.amazon.com/Ghost-towns-Gentry-County-Missouri/dp/B0006Y8CEG?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006Y8CEG",
        "ItemLinks" =>
        {
            "ItemLink" => [
            {
                "Description" => "Technical Details",
                "URL" => "https://www.amazon.com/Ghost-towns-Gentry-County-Missouri/dp/tech-data/B0006Y8CEG?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0006Y8CEG"
            },
            {
                "Description" => "Add To Baby Registry",
                "URL" => "https://www.amazon.com/gp/registry/baby/add-item.html?asin.0=B0006Y8CEG&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0006Y8CEG"
            },
            {
                "Description" => "Add To Wedding Registry",
                "URL" => "https://www.amazon.com/gp/registry/wedding/add-item.html?asin.0=B0006Y8CEG&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0006Y8CEG"
            },
            {
                "Description" => "Add To Wishlist",
                "URL" => "https://www.amazon.com/gp/registry/wishlist/add-item.html?asin.0=B0006Y8CEG&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0006Y8CEG"
            },
            {
                "Description" => "Tell A Friend",
                "URL" => "https://www.amazon.com/gp/pdp/taf/B0006Y8CEG?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0006Y8CEG"
            },
            {
                "Description" => "All Customer Reviews",
                "URL" => "https://www.amazon.com/review/product/B0006Y8CEG?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0006Y8CEG"
            },
            {
                "Description" => "All Offers",
                "URL" => "https://www.amazon.com/gp/offer-listing/B0006Y8CEG?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0006Y8CEG"
            }]
        },
        "SalesRank" => "13845240",
        "ItemAttributes" =>
        {
            "Author" => "Loy Layton Hammond", "Binding" => "Unknown Binding", "CatalogNumberList" =>
            {
                "CatalogNumberListElement" => "B0006Y8CEG"
            }, "Label" => "Farmer Printing Co", "Languages" =>
            {
                "Language" => [
                {
                    "Name" => "English",
                    "Type" => "Published"
                },
                {
                    "Name" => "English",
                    "Type" => "Unknown"
                }]
            }, "Manufacturer" => "Farmer Printing Co", "NumberOfPages" => "139", "PackageDimensions" =>
            {
                "Height" =>
                {
                    "__content__" => "60", "Units" => "hundredths-inches"
                }, "Length" =>
                {
                    "__content__" => "830", "Units" => "hundredths-inches"
                }, "Weight" =>
                {
                    "__content__" => "30", "Units" => "Hundredths Pounds"
                }, "Width" =>
                {
                    "__content__" => "580", "Units" => "hundredths-inches"
                }
            }, "ProductGroup" => "Book", "ProductTypeName" => "ABIS_BOOK", "PublicationDate" => "1972", "Publisher" => "Farmer Printing Co", "Studio" => "Farmer Printing Co", "Title" => "Ghost towns of Gentry County, Missouri"
        }
    },
    {
        "ASIN" => "B0000CKZ0S",
        "DetailPageURL" => "https://www.amazon.com/Becoming-Civilized-Psychological-Exploration-Africa/dp/B0000CKZ0S?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0000CKZ0S",
        "ItemLinks" =>
        {
            "ItemLink" => [
            {
                "Description" => "Technical Details",
                "URL" => "https://www.amazon.com/Becoming-Civilized-Psychological-Exploration-Africa/dp/tech-data/B0000CKZ0S?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0000CKZ0S"
            },
            {
                "Description" => "Add To Baby Registry",
                "URL" => "https://www.amazon.com/gp/registry/baby/add-item.html?asin.0=B0000CKZ0S&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0000CKZ0S"
            },
            {
                "Description" => "Add To Wedding Registry",
                "URL" => "https://www.amazon.com/gp/registry/wedding/add-item.html?asin.0=B0000CKZ0S&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0000CKZ0S"
            },
            {
                "Description" => "Add To Wishlist",
                "URL" => "https://www.amazon.com/gp/registry/wishlist/add-item.html?asin.0=B0000CKZ0S&SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0000CKZ0S"
            },
            {
                "Description" => "Tell A Friend",
                "URL" => "https://www.amazon.com/gp/pdp/taf/B0000CKZ0S?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0000CKZ0S"
            },
            {
                "Description" => "All Customer Reviews",
                "URL" => "https://www.amazon.com/review/product/B0000CKZ0S?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0000CKZ0S"
            },
            {
                "Description" => "All Offers",
                "URL" => "https://www.amazon.com/gp/offer-listing/B0000CKZ0S?SubscriptionId=AKIAIM5CZH6OERDFHP3Q&tag=vintagevideog-20&linkCode=xm2&camp=2025&creative=386001&creativeASIN=B0000CKZ0S"
            }]
        },
        "ItemAttributes" =>
        {
            "Author" => "Leonard W. Doob", "Binding" => "Hardcover", "CatalogNumberList" =>
            {
                "CatalogNumberListElement" => "B0000CKZ0S"
            }, "Edition" => "First Edition; First Impression", "Format" => "Import", "Label" => "Yale University Press", "Manufacturer" => "Yale University Press", "NumberOfItems" => "1", "NumberOfPages" => "33", "PackageDimensions" =>
            {
                "Height" =>
                {
                    "__content__" => "80", "Units" => "hundredths-inches"
                }, "Length" =>
                {
                    "__content__" => "930", "Units" => "hundredths-inches"
                }, "Weight" =>
                {
                    "__content__" => "170", "Units" => "Hundredths Pounds"
                }, "Width" =>
                {
                    "__content__" => "620", "Units" => "hundredths-inches"
                }
            }, "ProductGroup" => "Book", "ProductTypeName" => "ABIS_BOOK", "PublicationDate" => "1960", "Publisher" => "Yale University Press", "SKU" => "9928242452", "Studio" => "Yale University Press", "Title" => "Becoming More Civilized A Psychological Exploration (Zulu, Luto, Ganda of Africa)"
        }
    }]
}
		# p asin_concact

		items =  batches['Item'] 
		return items
		
	end

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
				asin.insert(0,'0')
				valid_asins << asin
			end
		end

		return valid_asins
	end

  def asins_test ten_prod_arr
    asin_length = ten_prod_arr.length
    if asin_length > 10 
      asins_1 = ten_prod_arr[0..9].join(',')
      asins_2 = ten_prod_arr[10..-1].join(',')
    else
      asins_1 = ten_prod_arr.join(',')
      asins_2 = ''
    end
    p asins_1
    p asins_2
  end

	def paapi_call ten_prod_arr
		# use vacuum gem
    request = Vacuum.new
   
		request.configure(
		  aws_access_key_id: 'AKIAIOXYKUVGX7Q44KXQ',
		  aws_secret_access_key: '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',
		  associate_tag: 'bharathvasan9-20 '
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
		# query = {
		# 	'ItemId' => asin_concact,
		# 	'SearchIndex' => 'All',
		# 	'ResponseGroup' => 'ItemAttributes, SalesRank',
		# 	'IdType' => 'ISBN'
		# }

    query = {
    'ItemLookup.1.ItemId': asins_1,# asins
    'ItemLookup.Shared.ResponseGroup': 'ItemAttributes, SalesRank', # response groups
    'ItemLookup.2.ItemId': asins_2# asins
    }

		begin
			response = request.item_lookup(query: query)
			puts response.status
			# Return up to 20 offers in an array.
			batches = response.dig('ItemLookupResponse', 'Items')
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
		rescue Excon::Error::ServiceUnavailable
      nil
    end
	end
end
