class CreateJoinTableTweetTwitterStream < ActiveRecord::Migration
  def change
    create_join_table :tweets, :twitter_streams do |t|
      # t.index [:tweet_id, :twitter_stream_id]
      # t.index [:twitter_stream_id, :tweet_id]
    end
  end
end
