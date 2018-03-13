class Inventory < ApplicationRecord
  def self.import_from_csv(file)

    inventories_json = []
		CSV.foreach(file.path, headers: true, :encoding => Encoding::ISO_8859_1) do | row |
   #    t = Inventory.new
			# t.name = row['item-name'] 
   #    t.listingID = row['listing-id']
   #    t.sellerSku = row['seller-sku']
   #    t.price = row['price']
   #    t.quantity = row['quantity']
   #    t.opendate = row['open-date']
   #    t.imageUrl = row['image-url']
   #    t.isMarketplace = row['item-is-marketplace']
   #    t.asin1 = row['asin1']
   #    t.asin2 = row['asin2']
   #    t.asin3 = row['asin3']
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
    end

    # get current Time 
    file_name = Time.now.to_s + "_inventory.json"
    File.open("public/inventory/#{file_name}", "w") do |file|
      file.write(inventories_json.to_json)
    end

    return file_name
  end
  
end
