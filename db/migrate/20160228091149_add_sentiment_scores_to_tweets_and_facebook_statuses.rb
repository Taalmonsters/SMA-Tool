class AddSentimentScoresToTweetsAndFacebookStatuses < ActiveRecord::Migration
  def change
    add_column :facebook_statuses, :sentiment, :float
    add_column :tweets, :sentiment, :float
  end
end
