require 'open-uri'
class FacebookSearch < ActiveRecord::Base
  enum status: [:waiting, :running, :finished]
  after_initialize :set_default_status, :if => :new_record?
  belongs_to :user
  has_and_belongs_to_many :facebook_statuses

  def set_default_status
    self.status ||= :waiting
  end
  
  def get_statuses
    p "*** GET STATUSES"
    self.update_attribute(:status, :running)
    Thread.new do
      @user.facebook.search(URI::encode(self.query.gsub(/[\n ]+/,"")), {:type => "page"}).each do |page|
        @user.facebook.get_connections(page["id"], "posts").each do |post|
          fb_status = FacebookStatus.from_idstr_and_uid(post["id"],page["id"])
          if !fb_status.blank? && !self.fb_statuses.include?(fb_status)
            self.fb_statuses << fb_status
          end
        end
      end
      self.update_attribute(:status, :finished)
    end
  end
end
