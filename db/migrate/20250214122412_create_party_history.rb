class CreatePartyHistory < ActiveRecord::Migration[8.0]
  def change
    create_table :party_histories do |t|
      t.references :member, foreign_key: true, index: true
      t.string :party_abbreviation
      t.string :party_name
      t.integer :start_year

      t.timestamps
    end
  end
end
