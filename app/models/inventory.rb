class Inventory < ApplicationRecord
  def self.import_from_csv(file)

    inventories_json = []
    i = 0
		# CSV.foreach(file.path, headers: true, :encoding => Encoding::ISO_8859_1) do | row |
    File.foreach(file.path) do |line|
      i += 1
      row = line.split("\t")
      # TXT Header Check
      headers = ["listing-id", "seller-sku", "price", "quantity", "open-date", "item-is-marketplace", "asin1", "status\n"]
      if i == 1
        p row
        headers.each do |header|
          return "Check your TXT file Columns!" unless row.include? header
        end
      else  
        if row[3] && row[16] # seller-sku, asin1
          inventory_json = {
            "item-name" => row[0],
            "listingID" => row[2],
            "sellerSku" => row[3],
            "price" => row[4],
            "quantity" => row[5],
            "opendate" => row[6],
            "isMarketplace" => row[8],
            "asin1" => row[16]
          }
          inventories_json << inventory_json
        else
          next
        end 
      end 
    end
    # get random string
    rand_str = SecureRandom.hex

    # get current Time to miliseconds string
    file_name = Time.now.to_i.to_s + rand_str
    File.open("#{Rails.root}/public/inventory/#{file_name}", "w") do |file|
      file.write(inventories_json.to_json)
    end

    return file_name
  end
  
end
