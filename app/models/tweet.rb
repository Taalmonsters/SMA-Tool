require 'csv'
class Tweet < ActiveRecord::Base
  has_and_belongs_to_many :twitter_streams
  has_and_belongs_to_many :twitter_searches
  has_and_belongs_to_many :twitter_id_searches
  has_and_belongs_to_many :hashtags
  
  def self.from_json(json)
    p "*** NEW TWEET: "+json['text']
    tweets = Tweet.where(:id_str => json['id_str'])
    if tweets.size > 0
      return tweets.first
    end
    tweet = Tweet.create(:id_str => json['id_str'], :text => json['text'].gsub(/\n+/," "), 
    :user_screen_name => json['user']['screen_name'], :user_location => json['user']['location'],
    :in_reply_to_status_id_str => json['in_reply_to_status_id_str'],
    :lang => json['lang'], :retweet_count => json['retweet_count'], 
    :favorite_count => json['favorite_count'], :created_at => json['created_at'])
    if tweet
      if json['entities']['hashtags'].size > 0
        json['entities']['hashtags'].each do |ht|
          p "*** HASHTAG"
          hashtag = Hashtag.find_by_tag(ht['text'])
          if !hashtag
            hashtag = Hashtag.create(:tag => ht['text'])
          end
          tweet.hashtags << hashtag
        end
      end
      tweet.set_sentiment_score
      return tweet
    end
    return nil
  end
  
  def set_sentiment_score
    if self.lang.eql?('nl')
      self.update_attribute(:sentiment, self.sentiment_analyzer_nl.analyze(self.text))
    elsif self.lang.eql?('en')
      self.update_attribute(:sentiment, self.sentiment_analyzer_en.analyze(self.text))
    end
  end
  
  def sentiment_analyzer_nl
    @analyzer_nl ||= SentimentLib::Analyzer.new(:strategy => SentimentAnalyzerDutch.new)
  end
  
  def sentiment_analyzer_en
    @analyzer_en ||= SentimentLib::Analyzer.new(:strategy => SentimentAnalyzerEnglish.new)
  end
  
  def self.to_csv(options = {})
    c = ['id_str', 'user_screen_name', 'user_location', 'text', 'lang', 'retweet_count', 'favorite_count', 'sentiment', 'in_reply_to_status_id_str', 'created_at']
    cc = c + ['hashtags']
    CSV.generate(options) do |csv|
      csv << cc
      all.each do |tweet|
        csv << tweet.attributes.values_at(*c) + [tweet.hashtags_string]
      end
    end
  end
  
  def hashtags_string
    arr = []
    self.hashtags.each do |hashtag|
      arr << hashtag.tag
    end
    arr.join(",")
  end
  
end
