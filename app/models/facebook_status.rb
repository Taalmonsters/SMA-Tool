class FacebookStatus < ActiveRecord::Base
  has_and_belongs_to_many :facebook_searches
  
  def self.from_idstr_and_uid(idstr,uid)
    facebook_status = FacebookStatus.find_by_id_str(idstr)
    if !facebook_status
      facebook_status = FacebookStatus.new
      facebook_status.id_str = idstr
      facebook_status.text = @user.facebook.get_object(idstr)['message']
      facebook_status.created_at = Time.at(@user.facebook.get_object(idstr)['created_time'])
      facebook_status.like_count = @user.facebook.get_connections(idstr, 'likes').size
      facebook_status.share_count = @user.facebook.get_connections(idstr, 'sharedposts').size
      facebook_status.user_screen_name = @user.facebook.get_object(uid, {:fields => ["name"]})['name']
      loc = @user.facebook.get_object(uid, {:fields => ["location"]})['location']
      facebook_status.user_location = loc.blank? ? '' : loc['name']
      facebook_status.save!
    end
    facebook_status
  end
  
  def self.to_csv(options = {})
    c = ['id_str', 'user_screen_name', 'user_location', 'text', 'share_count', 'like_count', 'created_at']
    CSV.generate(options) do |csv|
      csv << c
      all.each do |facebook_status|
        csv << facebook_status.attributes.values_at(*c)
      end
    end
  end
end
