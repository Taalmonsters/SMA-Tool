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
      if auth['info']
         user.name = auth['info']['name'] || ""
      end
    end
  end

end
