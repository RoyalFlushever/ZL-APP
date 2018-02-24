class CreateInventories < ActiveRecord::Migration[5.1]
  def change
    create_table :inventories do |t|
      t.string :name
      t.string :listingID
      t.string :sellerSku
      t.decimal :price
      t.integer :quantity
      t.timestamp :opendate
      t.string :imageUrl
      t.string :isMarketplace
      t.string :asin1
      t.string :asin2
      t.string :asin3

      t.timestamps
    end
    add_index :inventories, :listingID, unique: true
    add_index :inventories, :sellerSku, unique: true
    add_index :inventories, :asin1
  end
end
