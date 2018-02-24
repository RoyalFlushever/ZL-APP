class CreateApicredetials < ActiveRecord::Migration[5.1]
  def change
    create_table :apicredetials do |t|
      t.string :access_key
      t.string :secret_key
      t.string :associate_tag
      t.boolean :status

      t.timestamps
    end
  end
end
