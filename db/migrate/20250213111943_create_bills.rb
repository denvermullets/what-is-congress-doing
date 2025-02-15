class CreateBills < ActiveRecord::Migration[8.0]
  def change
    create_table :bills do |t|
      t.integer :congress
      t.string :number
      t.string :origin_chamber
      t.string :origin_chamber_code
      t.text :constitutional_authority_statement_text
      t.string :title
      t.string :bill_type
      t.datetime :update_date
      t.datetime :update_date_including_text
      t.date :introduced_date

      t.timestamps
    end
  end
end
