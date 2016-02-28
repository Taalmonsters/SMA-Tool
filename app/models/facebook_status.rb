require 'csv'
require 'wtf_lang'
WtfLang::API.key = ENV['WTF_LANG_API_KEY']
class FacebookStatus < ActiveRecord::Base
  has_and_belongs_to_many :facebook_searches
  
  def self.from_idstr_and_uid(idstr,uid,facebook,reaction_to,is_comment)
    if FacebookStatus.where(:id_str => idstr).any?
      p "*** FACEBOOK_STATUS EXISTS"
      return FacebookStatus.where(:id_str => idstr).first
    else
      obj = nil
      if is_comment
        obj = facebook.get_object(idstr, {:fields => ["likes.summary(true)", "message"]})
      else
        obj = facebook.get_object(idstr, {:fields => ["likes.summary(true)", "shares.summary(true)", "message"]})
      end
      if !obj.has_key?('message') || obj['message'].blank? || obj['message'] !~ /^[a-zA-Z0-9\.\,\+\:\)\(\;\'\"\-\_\*\#\@\!\$\%\&\? ]+$/ || obj['message'] =~ /^[0-9\.\,\+\:\)\(\;\'\"\-\_\*\#\@\!\$\%\&\? ]+$/
        return nil
      end
      p "*** NEW FACEBOOK_STATUS "+idstr
      lc = obj['likes']['summary']['total_count']
      p "*** LC: "+lc.to_s
      sc = 0
      if obj.has_key?('shares') && obj['shares'].has_key?('count')
        sc = obj['shares']['count']
      end
      p "*** SC: "+sc.to_s
      uname = facebook.get_object(uid, {:fields => ["name"]})['name']
      p "*** UNAME: "+uname
      uloc = self.get_user_location(uid,facebook)
      p "*** ULOC: "+uloc
      text = obj['message'].gsub(/\n+/," ")
      p "*** TEXT: "+text
      l = ''
      begin
        l = text.lang
      rescue
        
      end
      # l = text.lang
      p "*** LANG: "+l
      st = FacebookStatus.create(
        :id_str => idstr,
        :in_reply_to_status_id_str => reaction_to.blank? ? '' : reaction_to,
        :text => text,
        :created_at => DateTime.strptime(facebook.get_object(idstr)['created_time'], '%Y-%m-%dT%H:%M:%S%z'),
        :like_count => lc,
        :share_count => sc,
        :user_screen_name => uname,
        :user_location => uloc,
        :lang => l
      )
      if st && !st.errors.any?
        st.set_sentiment_score
        return st
      end
    end
    return nil
  end
  
  def set_sentiment_score
    if !self.lang.blank? && self.text.length < 600
      if self.lang.eql?('nl')
        self.update_attribute(:sentiment, self.sentiment_analyzer_nl.analyze(self.text))
      elsif self.lang.eql?('en')
        self.update_attribute(:sentiment, self.sentiment_analyzer_en.analyze(self.text))
      end
    end
  end
  
  def sentiment_analyzer_nl
    if Rails.configuration.x.sentiment_analyzer.nl == nil
      Rails.configuration.x.sentiment_analyzer.nl = SentimentLib::Analyzer.new(:strategy => SentimentAnalyzerDutch.new)
    end
    Rails.configuration.x.sentiment_analyzer.nl
  end
  
  def sentiment_analyzer_en
    if Rails.configuration.x.sentiment_analyzer.en == nil
      Rails.configuration.x.sentiment_analyzer.en = SentimentLib::Analyzer.new(:strategy => SentimentAnalyzerEnglish.new)
    end
    Rails.configuration.x.sentiment_analyzer.en
  end
  
  def self.get_user_location(uid,facebook)
    loc = facebook.get_object(uid, {:fields => ["location"]})
    if loc.blank? || !loc.has_key?('location') || !loc['location'].has_key?('name')
      return ''
    else
      return loc['location']['name']
    end
  end
  
  def self.to_csv(options = {})
    c = ['id_str', 'user_screen_name', 'user_location', 'text', 'lang', 'share_count', 'like_count', 'sentiment', 'in_reply_to_status_id_str', 'created_at']
    CSV.generate(options) do |csv|
      csv << c
      all.each do |facebook_status|
        csv << facebook_status.attributes.values_at(*c)
      end
    end
  end
end
