class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :id_str
      t.string :text
      t.string :lang
      t.string :in_reply_to_status_id_str
      t.string :user_screen_name
      t.string :user_location
      t.integer :retweet_count
      t.integer :favorite_count

      t.timestamps null: false
    end
  end
end
