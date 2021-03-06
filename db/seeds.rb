# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

csv_text = File.read(Rails.root.join('lib', 'seeds', 'inventory.csv'))
csv = CSV.parse(csv_text,  :headers => true, :encoding => Encoding::ISO_8859_1)

csv.each do | row |
	# puts row.to_hash
	t = Inventory.new
	t.name = row['item-name'] 
  t.listingID = row['listing-id']
  t.sellerSku = row['seller-sku']
  t.price = row['price']
  t.quantity = row['quantity']
  t.opendate = row['open-date']
  t.imageUrl = row['image-url']
  t.isMarketplace = row['item-is-marketplace']
  t.asin1 = row['asin1']
  t.asin2 = row['asin2']
  t.asin3 = row['asin3']
  t.save
  puts "#{t.name}, #{t.asin1} saved "

end