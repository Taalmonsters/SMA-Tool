class CreateFacebookStatuses < ActiveRecord::Migration
  def change
    create_table :facebook_statuses do |t|
      t.string :id_str
      t.text :text
      t.string :user_screen_name
      t.string :user_location
      t.integer :share_count
      t.integer :like_count

      t.timestamps null: false
    end
  end
end
