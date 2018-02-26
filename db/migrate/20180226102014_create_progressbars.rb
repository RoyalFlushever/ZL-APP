class CreateProgressbars < ActiveRecord::Migration[5.1]
  def change
    create_table :progressbars do |t|
      t.string :taskname
      t.integer :percent
      t.string :message
      t.integer :status
      t.decimal :tradein
      t.decimal :buyback
      t.decimal :profit

      t.timestamps
    end
    add_index :progressbars, :taskname, unique: true
  end
end
