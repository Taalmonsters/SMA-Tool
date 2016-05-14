class CreateTwitterGraphs < ActiveRecord::Migration
  def change
    create_table :twitter_graphs do |t|
      t.string :query
      t.string :output
      t.integer :status
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
