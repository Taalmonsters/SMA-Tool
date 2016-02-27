class CreateJoinTableTweetHashtag < ActiveRecord::Migration
  def change
    create_join_table :tweets, :hashtags do |t|
      # t.index [:tweet_id, :hashtag_id]
      # t.index [:hashtag_id, :tweet_id]
    end
  end
end
