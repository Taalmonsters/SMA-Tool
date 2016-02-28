require 'open-uri'
class FacebookSearch < ActiveRecord::Base
  enum status: [:waiting, :running, :finished]
  after_initialize :set_default_status, :if => :new_record?
  belongs_to :user
  has_and_belongs_to_many :facebook_statuses

  def set_default_status
    self.status ||= :waiting
  end
  
  def self.is_terminated?(id)
    el = FacebookSearch.find(id)
    el == nil || el.status.to_s.eql?('finished')
  end
  
  def get_statuses(facebook)
    p "*** GET STATUSES"
    self.update_attribute(:status, :running)
    Thread.new do
      page_collection = facebook.search(self.query, {:type => "page", :limit => 1000})
      terminated = false
      if page_collection.size > 0
        begin
          page_collection.each do |page|
            terminated = FacebookSearch.is_terminated?(self.id)
            unless terminated
              p "*** PAGE: "+page["id"]
              posts_collection = facebook.get_connections(page["id"], "posts", limit: 100, filter: 'stream')
              p "*** TERMINATED: "+terminated.to_s
              if posts_collection.size > 0
                begin
                  posts_collection.each do |post|
                    p "*** POST: "+post["id"]
                    terminated = FacebookSearch.is_terminated?(self.id)
                    unless terminated
                      p "*** POST: "+post["id"]
                      facebook_status = FacebookStatus.from_idstr_and_uid(post["id"],page["id"],facebook,nil,false)
                      if facebook_status != nil && !self.facebook_statuses.include?(facebook_status)
                        self.facebook_statuses << facebook_status
                        # Get comments to status
                        comment_count = facebook.get_object(post["id"], {:fields => "comments.summary(true)"})['comments']['summary']['total_count']
                        p "*** COMMENT COUNT: "+comment_count.to_s
                        if comment_count > 0
                          comments = facebook.get_connections(post["id"], "comments", limit: 100, filter: 'stream')
                          begin
                            comments.each do |comment|
                              terminated = FacebookSearch.is_terminated?(self.id)
                              unless terminated
                                comment_status = FacebookStatus.from_idstr_and_uid(comment["id"],comment["from"]["id"],facebook,post["id"],true)
                                if comment_status != nil && !self.facebook_statuses.include?(comment_status)
                                  self.facebook_statuses << comment_status
                                end
                              end
                            end
                            comments = comments.next_page
                          end while comments != nil && !terminated
                        end
                      end
                    end
                  end
                  posts_collection = posts_collection.next_page
                end while posts_collection != nil && !terminated
              end
            end
          end
          page_collection = page_collection.next_page
        end while page_collection != nil && !terminated
      end
      self.update_attribute(:status, :finished)
    end
  end
end
