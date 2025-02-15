class CreateLatestAction < ActiveRecord::Migration[8.0]
  def change
    create_table :latest_actions do |t|
      t.references :bill, foreign_key: true, index: true
      t.string :action_date
      t.text :text

      t.timestamps
    end
  end
end
