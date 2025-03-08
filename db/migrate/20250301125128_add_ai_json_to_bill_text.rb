class AddAiJsonToBillText < ActiveRecord::Migration[8.0]
  def change
    add_column :bill_texts, :ai_json, :jsonb
  end
end
