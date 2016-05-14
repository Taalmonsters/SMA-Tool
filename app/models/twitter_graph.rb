require 'open-uri'
class TwitterGraph < ActiveRecord::Base
  enum status: [:waiting, :running, :finished]
  after_initialize :set_default_status, :if => :new_record?
  belongs_to :user
  validates :query, presence: true
  before_destroy :delete_output

  def set_default_status
    self.status ||= :waiting
  end
  
  def self.is_terminated?(id)
    el = TwitterSearch.find(id)
    el == nil || el.status.to_s.eql?('finished')
  end
  
  def delete_output
    if self.output && File.exists?(self.output)
      FileUtils.rm(self.output)
    end
  end
  
  def terminated
    self.finished?
  end
  
  def get_graph
    self.update_attribute(:status, :running)
    Thread.new do
      begin
        tw_auth = TwitterAuth.where(:user_id => self.user_id).first
        access_token = prepare_access_token(tw_auth.consumer_key, tw_auth.consumer_secret, tw_auth.access_token, tw_auth.access_secret)
        main_user = get_user(self.query, access_token)
        edges = []
        if main_user
          sleep(5 * User.find(self.user_id).active_twitter_threads)
          nodes, edges = get_uid_data(main_user, edges, access_token, [])
          nodes.each do |node|
            n, edges = get_uid_data(node, edges, access_token, nodes + [main_user])
          end
          file = Rails.root.join("data", "twitter_graph_"+self.id.to_s+".csv")
          File.open(file, "w") do |f|
            edges.each do |edge|
              f.write(edge[0]["screen_name"]+","+edge[1]["screen_name"]+"\n")
            end
          end
          self.update_attribute(:output, file)
        else
          logger.warn "User not found: "+self.query
        end
        self.update_attribute(:status, :finished)
      rescue => e
        p e.message
        p e.backtrace.join("\n")
        self.update_attribute(:status, :finished)
      end
    end
  end
  
  def get_uid_data(node, edges, access_token, set)
    nodes = []
    friends = nil
    followers = nil
    # if set.size > 0
      # friends = get_mutual_friends_list(node["id"].to_s, set, access_token)
      # sleep(30 * User.find(self.user_id).active_twitter_threads)
      # followers = get_mutual_followers_list(node["id"].to_s, set, access_token)
      # sleep(30 * User.find(self.user_id).active_twitter_threads)
    # else
      friends = get_friends_list(node["id"].to_s, access_token)
      sleep(30 * User.find(self.user_id).active_twitter_threads)
      followers = get_followers_list(node["id"].to_s, access_token)
      sleep(30 * User.find(self.user_id).active_twitter_threads)
    # end
    if friends
      friends.each do |friend|
        nodes << friend unless nodes.include?(friend)
        edge = [node, friend]
        unless edges.include?(edge)
          edges << edge
        end
      end
    end
    if followers
      followers.each do |follower|
        nodes << follower unless nodes.include?(follower)
        edge = [follower, node]
        unless edges.include?(edge)
          edges << edge
        end
      end
    end
    return nodes, edges
  end
  
  def get_followers_list(uid, access_token)
    return nil if terminated
    key = get_key(uid)
    url = "https://api.twitter.com/1.1/followers/list.json?"+key+"="+uid+"&skip_status=true&include_user_entities=false"
    response = access_token.get(url)
    response = JSON.parse(response.body)
    if response.has_key?("errors")
      logger.error response["errors"]
      return nil
    end
    response["users"]
  end
  
  def get_friends_list(uid, access_token)
    return nil if terminated
    key = get_key(uid)
    url = "https://api.twitter.com/1.1/friends/list.json?"+key+"="+uid+"&skip_status=true&include_user_entities=false"
    response = access_token.get(url)
    response = JSON.parse(response.body)
    if response.has_key?("errors")
      logger.error response["errors"]
      return nil
    end
    response["users"]
  end
  
  def get_mutual_friends_list(uid, set, access_token)
    return nil if terminated
    friends = []
    key = get_key(uid).sub(/user_/,"")
    ids = set.map{|x| x["id"].to_s }.join(",")
    url = "https://api.twitter.com/1.1/friendships/show.json?source_"+key+"="+uid+"&target_id="+ids
    response = access_token.get(url)
    response = JSON.parse(response.body)
    return nil if response.has_key?("errors")
    response["relationships"].each do |rel|
      if rel["target"]["followed_by"].to_s.eql?("true")
        friends << rel["target"] unless friends.include?(rel["target"])
      end
    end
    friends
  end
  
  def get_mutual_followers_list(uid, set, access_token)
    return nil if terminated
    followers = []
    key = get_key(uid).sub(/user_/,"")
    ids = set.map{|x| x["id"].to_s }.join(",")
    url = "https://api.twitter.com/1.1/friendships/show.json?source_"+key+"="+uid+"&target_id="+ids
    response = access_token.get(url)
    response = JSON.parse(response.body)
    return nil if response.has_key?("errors")
    response["relationships"].each do |rel|
      if rel["target"]["following"].to_s.eql?("true")
        followers << rel["target"] unless followers.include?(rel["target"])
      end
    end
    followers
  end
  
  def get_user(uid, access_token)
    return nil if terminated
    key = get_key(uid)
    url = "https://api.twitter.com/1.1/users/show.json?"+key+"="+uid+"&include_entities=false"
    response = access_token.get(url)
    response = JSON.parse(response.body)
    if response.has_key?("errors")
      logger.error response["errors"]
      return nil
    end
    response
  end
  
  def get_key(uid)
    if uid =~ /^[0-9]+$/
      return "user_id"
    end
    return "screen_name"
  end
  
  def prepare_access_token(consumer_key, consumer_secret, oauth_token, oauth_token_secret)
    consumer = OAuth::Consumer.new(consumer_key, consumer_secret, { :site => "https://api.twitter.com", :scheme => :header })
    token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
    access_token = OAuth::AccessToken.from_hash(consumer, token_hash)
    return access_token
  end
end
