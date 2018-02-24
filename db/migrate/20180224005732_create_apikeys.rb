class CreateApikeys < ActiveRecord::Migration[5.1]
  def change
    create_table :apikeys do |t|
      t.string :access_key
      t.string :secret_key
      t.boolean :assigned

      t.timestamps
    end
  end
end
