class CreateJoinTableTweetTwitterSearch < ActiveRecord::Migration
  def change
    create_join_table :tweets, :twitter_searches do |t|
      # t.index [:tweet_id, :twitter_search_id]
      # t.index [:twitter_search_id, :tweet_id]
    end
  end
end
