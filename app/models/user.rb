require 'csv'
class User < ActiveRecord::Base
  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, :if => :new_record?
  has_one :twitter_auth
  has_many :twitter_streams
  has_many :twitter_searches
  has_many :twitter_id_searches
  has_many :facebook_searches
  accepts_nested_attributes_for :twitter_auth, allow_destroy: true

  def set_default_role
    if User.count == 0
      self.role ||= :admin
    else
      self.role ||= :user
    end
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      user.oauth_token = auth['credentials']['token']
      user.oauth_expires_at = Time.at(auth['credentials']['expires_at'])
      if auth['info']
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] || ""
      end
    end
  end
  
  def facebook
    Koala::Facebook::API.new(oauth_token)
  end
  
  def active_twitter_threads
    twitter_streams.where(:status => 1).size + twitter_searches.where(:status => 1).size + twitter_id_searches.where(:status => 1).size
  end
  
  def has_data?
    if self.twitter_streams.any? || self.twitter_searches.any? || self.twitter_id_searches.any? || self.facebook_searches.any?
      return true
    end
    return false
  end
  
  def has_valid_twitter_auth?
    !twitter_auth.blank? && !twitter_auth.access_token.blank? && !twitter_auth.access_secret.blank? && !twitter_auth.consumer_key.blank? && !twitter_auth.consumer_secret.blank?
  end
  
  def has_open_facebook_slots?
    !facebook_searches.where(:status => 1).any?
  end
  
  def has_open_twitter_slots?
    twitter_searches.where(:status => 1).size + twitter_streams.where(:status => 1).size < 2
    # !twitter_searches.where(:status => 1).any? && !twitter_streams.where(:status => 1).any?
  end
  
  def csv_data(options = {})
    c = ['query', 'result_type', 'id_str', 'user_screen_name', 'user_location', 'text', 'lang', 'retweet_count/share_count', 'favorite_count/like_count', 'sentiment', 'in_reply_to_status_id_str', 'created_at', 'hashtags']
    ctw = ['id_str', 'user_screen_name', 'user_location', 'text', 'lang', 'retweet_count', 'favorite_count', 'sentiment', 'in_reply_to_status_id_str', 'created_at']
    cfb = ['id_str', 'user_screen_name', 'user_location', 'text', 'lang', 'share_count', 'like_count', 'sentiment', 'in_reply_to_status_id_str', 'created_at']
    CSV.generate(options) do |csv|
      csv << c
      tweets_by_query = {}
      if self.twitter_streams.any?
        self.twitter_streams.each do |twitter_stream|
          if !tweets_by_query.has_key?(twitter_stream.query)
            tweets_by_query[twitter_stream.query] = []
          end
          tweets_by_query[twitter_stream.query] = tweets_by_query[twitter_stream.query] | twitter_stream.tweets
        end
      end
      if self.twitter_searches.any?
        self.twitter_searches.each do |twitter_search|
          if !tweets_by_query.has_key?(twitter_search.query)
            tweets_by_query[twitter_search.query] = []
          end
          tweets_by_query[twitter_search.query] = tweets_by_query[twitter_search.query] | twitter_search.tweets
        end
      end
      if self.twitter_id_searches.any?
        self.twitter_id_searches.each do |twitter_id_search|
          if !tweets_by_query.has_key?(twitter_id_search.query)
            tweets_by_query[twitter_id_search.query] = []
          end
          tweets_by_query[twitter_id_search.query] = tweets_by_query[twitter_id_search.query] | twitter_id_search.tweets
        end
      end
      tweets_by_query.each do |query, tweets|
        tweets.each do |tweet|
          csv << [query, 'tweet'] + tweet.attributes.values_at(*ctw) + [tweet.hashtags_string]
        end
      end
      
      if self.facebook_searches.any?
        self.facebook_searches.each do |facebook_search|
          facebook_search.facebook_statuses.each do |facebook_status|
            csv << [facebook_search.query, 'facebook_status'] + facebook_status.attributes.values_at(*cfb) + [""]
          end
        end
      end
    end
  end

end
