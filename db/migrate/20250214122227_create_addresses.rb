class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :member, foreign_key: true, index: true
      t.string :city
      t.string :district
      t.string :office_address
      t.string :phone_number
      t.integer :zip_code

      t.timestamps
    end
  end
end
