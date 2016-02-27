require 'open-uri'
class TwitterStream < ActiveRecord::Base
  enum status: [:waiting, :running, :finished]
  after_initialize :set_default_status, :if => :new_record?
  belongs_to :user
  has_and_belongs_to_many :tweets

  def set_default_status
    self.status ||= :waiting
  end
  
  def is_expired
    DateTime.now.utc > self.created_at + self.period.days
  end
  
  def expiration_date
    self.created_at + self.period.days
  end
  
  def get_stream
    self.update_attribute(:status, :running)
    Thread.new do
      tw_auth = TwitterAuth.where(:user_id => self.user_id).first
      TweetStream.configure do |config|
        config.consumer_key       = tw_auth.consumer_key
        config.consumer_secret    = tw_auth.consumer_secret
        config.oauth_token        = tw_auth.access_token
        config.oauth_token_secret = tw_auth.access_secret
        config.auth_method        = :oauth
      end
      TweetStream::Client.new.track(URI::encode(self.search_term)) do |status, client|
        tweet = Tweet.from_json(JSON.parse(status.to_json))
        if !tweet.blank? && !self.tweets.include?(tweet)
          self.tweets << tweet
        end
        if self.is_expired
          p "*** TERMINATING TWEET STREAM "+self.id.to_s
          client.stop
          self.update_attribute(:status, :finished)
        end
        sleep(5 * TwitterStream.where(:user_id => self.user_id).size)
      end
      self.update_attribute(:status, :finished)
    end
  end
  
  
end
