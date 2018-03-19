class Inventory < ApplicationRecord
  def self.import_from_csv(file)

    inventories_json = []
		CSV.foreach(file.path, headers: true, :encoding => Encoding::ISO_8859_1) do | row |
      # CSV Header Check
      # 
      headers = ["item-name", "listing-id", "seller-sku", "price", "quantity", "open-date", "item-is-marketplace", "asin1"]
      headers.each do |header|
        return "Check your CSV file Columns!" unless row.headers.include? header
      end

      if row['seller-sku'] && row['asin1'] 
        inventory_json = {
          "item-name" => row['item-name'],
          "listingID" => row['listing-id'],
          "sellerSku" => row['seller-sku'],
          "price" => row['price'],
          "quantity" => row['quantity'],
          "opendate" => row['open-date'],
          "isMarketplace" => row['item-is-marketplace'],
          "asin1" => row['asin1']
        }
        inventories_json << inventory_json
      else
        next
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
