class CreateBillText < ActiveRecord::Migration[8.0]
  def change
    create_table :bill_texts do |t|
      t.belongs_to :bill

      t.text :bill_text
      t.text :result

      t.timestamps
    end
  end
end
