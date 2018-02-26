require 'AmazonAPI'

class CallApiJob < ActiveJob::Base 

  queue_as :default

  def perform(filename)
  	@progress_bar = Progressbar.find_by(taskname: filename)
    2.times do |i|
    	sleep(1)
      @progress_bar.update_attributes!(percent: i * 10)
    end

    # open inventory json file
    file = File.read('public/inventory/' + filename )
    data_hash = JSON.parse(file)
    
    # make request to Amazon API
    request = AmazonAPI.new
    data_hash.each do | listing_item |
    	url = request.geturl listing_item["asin1"]
    	puts url
    	response = HTTParty.get(url)
    	puts response.code
    	puts response.message
    	case response.code
			  when 200
			    puts "All good!"
			  when 404
			    puts "O noes not found!"
			  when 500...600
			    puts "ZOMG ERROR #{response.code}"
			end

    	item_hash = response["ItemLookupResponse"]["Items"]["Item"]
    	# ASIN
     	puts item_hash["ASIN"]
    end
  end

end
	