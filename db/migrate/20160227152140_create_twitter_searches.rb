class CreateTwitterSearches < ActiveRecord::Migration
  def change
    create_table :twitter_searches do |t|
      t.string :query
      t.integer :status
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
