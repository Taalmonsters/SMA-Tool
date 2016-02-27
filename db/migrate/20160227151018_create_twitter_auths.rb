class CreateTwitterAuths < ActiveRecord::Migration
  def change
    create_table :twitter_auths do |t|
      t.string :consumer_key
      t.string :consumer_secret
      t.string :access_token
      t.string :access_secret
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
