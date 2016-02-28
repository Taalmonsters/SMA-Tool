require 'csv'
require 'wtf_lang'
WtfLang::API.key = "cf61c2ea74690c53839df12d97018826"
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
      if !obj.has_key?('message') || obj['message'].blank? || obj['message'] !~ /^[a-zA-Z0-9\.\,\+\:\)\(\;\'\"\-\_\*\#\@\!\$\%\&\? ]+$/
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
      l = text.lang
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
      if st.errors.any?
        p "*** ERROR: COULD NOT SAVE FACEBOOK_STATUS"
        p st.errors.values.join("\n")
        return nil
      else
        p "*** NEW FACEBOOK_STATUS CREATED"
        return st
      end
    end
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
