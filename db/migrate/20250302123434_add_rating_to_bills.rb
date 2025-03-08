class AddRatingToBills < ActiveRecord::Migration[8.0]
  def change
    add_column :bills, :rating, :integer
  end
end
