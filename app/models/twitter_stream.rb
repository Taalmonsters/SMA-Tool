require 'open-uri'
class TwitterStream < ActiveRecord::Base
  enum status: [:waiting, :running, :finished]
  after_initialize :set_default_status, :if => :new_record?
  belongs_to :user
  has_and_belongs_to_many :tweets
  validates :query, presence: true

  def set_default_status
    self.status ||= :waiting
  end
  
  def self.is_terminated?(id)
    el = TwitterStream.find(id)
    el == nil || el.status.to_s.eql?('finished')
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
      terminated = false
      tw_auth = TwitterAuth.where(:user_id => self.user_id).first
      TweetStream.configure do |config|
        config.consumer_key       = tw_auth.consumer_key
        config.consumer_secret    = tw_auth.consumer_secret
        config.oauth_token        = tw_auth.access_token
        config.oauth_token_secret = tw_auth.access_secret
        config.auth_method        = :oauth
      end
      TweetStream::Client.new.track(URI::encode(self.query)) do |status, client|
        terminated = TwitterStream.is_terminated?(self.id)
        unless terminated
          tweet = Tweet.from_json(JSON.parse(status.to_json))
          if !tweet.blank? && !self.tweets.include?(tweet)
            self.tweets << tweet
          end
        end
        if terminated || self.is_expired
          p "*** TERMINATING TWEET STREAM "+self.id.to_s
          client.stop
          self.update_attribute(:status, :finished)
        else
          sleep(5 * User.find(self.user_id).active_twitter_threads)
        end
      end
      # self.update_attribute(:status, :finished)
    end
  end
  
  
end
