class CreateBillCoSponsor < ActiveRecord::Migration[8.0]
  def change
    create_table :bill_co_sponsors do |t|
      t.references :bill, foreign_key: true, index: true
      t.references :member, foreign_key: true, index: true

      t.timestamps
    end
  end
end
