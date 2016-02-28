require 'open-uri'
class FacebookSearch < ActiveRecord::Base
  enum status: [:waiting, :running, :finished]
  after_initialize :set_default_status, :if => :new_record?
  belongs_to :user
  has_and_belongs_to_many :facebook_statuses

  def set_default_status
    self.status ||= :waiting
  end
  
  def get_statuses(facebook)
    p "*** GET STATUSES"
    self.update_attribute(:status, :running)
    Thread.new do
      page_collection = facebook.search(self.query, {:type => "page", :limit => 1000})
      begin
        page_collection.each do |page|
          p "*** PAGE: "+page["id"]
          posts_collection = facebook.get_connections(page["id"], "posts", limit: 100, filter: 'stream')
          begin
            posts_collection.each do |post|
              p "*** POST: "+post["id"]
              facebook_status = FacebookStatus.from_idstr_and_uid(post["id"],page["id"],facebook,nil,false)
              if !facebook_status.blank? && !self.facebook_statuses.include?(facebook_status)
                p "*** SUCCESS"
                self.facebook_statuses << facebook_status
                # Get comments to status
                comment_count = facebook.get_object(post["id"], {:fields => "comments.summary(true)"})['comments']['summary']['total_count']
                p "*** COMMENT COUNT: "+comment_count.to_s
                if comment_count > 0
                  comments = facebook.get_connections(post["id"], "comments", limit: 100, filter: 'stream')
                  begin
                    comments.each do |comment|
                      comment_status = FacebookStatus.from_idstr_and_uid(comment["id"],comment["from"]["id"],facebook,post["id"],true)
                      if !comment_status.blank? && !self.facebook_statuses.include?(comment_status)
                        self.facebook_statuses << comment_status
                      end
                    end
                    comments = comments.next_page
                  end while comments != nil
                end
              else
                p "*** ERROR"
              end
            end
            posts_collection = posts_collection.next_page
          end while posts_collection != nil
        end
        page_collection = page_collection.next_page
      end while page_collection != nil
      self.update_attribute(:status, :finished)
    end
  end
end
