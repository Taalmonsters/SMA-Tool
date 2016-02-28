require 'open-uri'
class TwitterSearch < ActiveRecord::Base
  enum status: [:waiting, :running, :finished]
  after_initialize :set_default_status, :if => :new_record?
  belongs_to :user
  has_and_belongs_to_many :tweets

  def set_default_status
    self.status ||= :waiting
  end
  
  def get_tweets
    self.update_attribute(:status, :running)
    p "*** GET TWEETS"
    Thread.new do
      tw_auth = TwitterAuth.where(:user_id => self.user_id).first
      access_token = prepare_access_token(tw_auth.consumer_key, tw_auth.consumer_secret, tw_auth.access_token, tw_auth.access_secret)
      (0..8).to_a.reverse.each do |i|
        date = (Time.now - i.days).strftime("%Y-%m-%d")
        p "*** DATE: "+date.to_s
        url = "https://api.twitter.com/1.1/search/tweets.json?result_type=mixed&until="+date+"&count=100&q="+URI::encode(self.query.gsub(/[\n ]+/,""))
        begin
          response = access_token.get(url)
          response = JSON.parse(response.body)
          if response.has_key?("errors")
            p "*** ERROR: "+response["errors"][0]["message"]
            if response["errors"][0]["code"] == 88
              sleep(900)
              response = access_token.get(url)
              response = JSON.parse(response.body)
            else
              response = nil
              url = nil
            end
          end
          if response != nil
            response["statuses"].each do |status|
              tweet = Tweet.from_json(status)
              if !tweet.blank? && !self.tweets.include?(tweet)
                self.tweets << tweet
              end
            end
            if response["search_metadata"].has_key?("next_results") && !response["search_metadata"]["next_results"].blank?
              url = "https://api.twitter.com/1.1/search/tweets.json"+response["search_metadata"]["next_results"]
            else
              url = nil
            end
            sleep(5 * User.find(self.user_id).active_twitter_threads)
          end
        end while url != nil
      end
      self.update_attribute(:status, :finished)
    end
  end
  
  def prepare_access_token(consumer_key, consumer_secret, oauth_token, oauth_token_secret)
    consumer = OAuth::Consumer.new(consumer_key, consumer_secret, { :site => "https://api.twitter.com", :scheme => :header })
    token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
    access_token = OAuth::AccessToken.from_hash(consumer, token_hash)
    return access_token
  end
end
