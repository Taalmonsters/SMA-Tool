class CreateTwitterIdSearches < ActiveRecord::Migration
  def change
    create_table :twitter_id_searches do |t|
      t.text :query
      t.integer :status
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
