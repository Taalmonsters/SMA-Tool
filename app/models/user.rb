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
    p "*** CREATE WITH OMNIAUTH"
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
    @facebook ||= Koala::Facebook::API.new(oauth_token)
  end
  
  def search(query)
    facebook.search(query, { :type => 'post' })
  end
  
  def facebook_profile
    facebook.get_object("me")
  rescue Koala::Facebook::APIError => e
    logger.info e.to_s
    nil
  end
  
  def friends_count
    facebook.get_connection("me", "friends").size
  rescue Koala::Facebook::APIError => e
    logger.info e.to_s
    nil
  end

end
