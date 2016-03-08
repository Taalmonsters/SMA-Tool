class TwitterIdSearch < ActiveRecord::Base
  enum status: [:waiting, :running, :finished]
  after_initialize :set_default_status, :if => :new_record?
  belongs_to :user
  has_and_belongs_to_many :tweets
  validates :query, presence: true

  def set_default_status
    self.status ||= :waiting
  end
  
  def get_tweets
    self.update_attribute(:status, :running)
    tw_auth = TwitterAuth.where(:user_id => self.user_id).first
    access_token = prepare_access_token(tw_auth.consumer_key, tw_auth.consumer_secret, tw_auth.access_token, tw_auth.access_secret)
    url = "https://api.twitter.com/1.1/statuses/lookup.json?id="+self.query.gsub(/[\n ]+/,"")
    response = access_token.get(url)
    response = JSON.parse(response.body)
    if response != nil
      response.each do |status|
        tweet = Tweet.from_json(status)
        if !tweet.blank? && !self.tweets.include?(tweet)
          self.tweets << tweet
        end
      end
    end
    self.update_attribute(:status, :finished)
  end
  
  def prepare_access_token(consumer_key, consumer_secret, oauth_token, oauth_token_secret)
    consumer = OAuth::Consumer.new(consumer_key, consumer_secret, { :site => "https://api.twitter.com", :scheme => :header })
    token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
    access_token = OAuth::AccessToken.from_hash(consumer, token_hash)
    return access_token
  end
  
end
