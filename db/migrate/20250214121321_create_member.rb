class CreateMember < ActiveRecord::Migration[8.0]
  def change
    create_table :members do |t|
      t.string :bio_guide_id
      t.string :birth_year
      t.boolean :current_member
      t.string :direct_order_name
      t.integer :district
      t.string :first_name
      t.string :honorific_name
      t.string :inverted_order_name
      t.string :last_name
      t.string :middle_name
      t.string :display_name
      t.string :official_website_url
      t.string :state
      t.datetime :update_date
      t.string :image_attribution
      t.string :image_url
      t.string :party

      t.timestamps
    end
  end
end
