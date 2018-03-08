class AddTotalToProgressbars < ActiveRecord::Migration[5.1]
  def change
    add_column :progressbars, :total, :decimal
  end
end
