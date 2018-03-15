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
      # CSV Header Check
      # 
      headers = ["item-name", "item-description", "listing-id", "seller-sku", "price", "quantity", "open-date", "image-url", "item-is-marketplace", "product-id-type", "zshop-shipping-fee", "item-note", "item-condition", "zshop-category1", "zshop-browse-path", "zshop-storefront-feature", "asin1", "asin2", "asin3", "will-ship-internationally", "expedited-shipping", "zshop-boldface", "product-id", "bid-for-featured-placement", "add-delete", "pending-quantity", "fulfillment-channel"]
      p row.headers
      return "Check your CSV file Columns!" unless row.headers.sort == headers.sort

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
    # get random value
    rand_str = SecureRandom.hex

    # get current Time to miliseconds string
    file_name = Time.now.to_i.to_s + rand_str + "_inventory.json"
    File.open("#{Rails.root}/public/inventory/#{file_name}", "w") do |file|
      file.write(inventories_json.to_json)
    end

    return file_name
  end
  
end
