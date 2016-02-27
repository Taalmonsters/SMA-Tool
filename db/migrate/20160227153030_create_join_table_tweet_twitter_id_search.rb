class CreateJoinTableTweetTwitterIdSearch < ActiveRecord::Migration
  def change
    create_join_table :tweets, :twitter_id_searches do |t|
      # t.index [:tweet_id, :twitter_id_search_id]
      # t.index [:twitter_id_search_id, :tweet_id]
    end
  end
end
