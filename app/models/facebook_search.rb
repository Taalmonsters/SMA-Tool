require 'open-uri'
class FacebookSearch < ActiveRecord::Base
  enum status: [:running, :finished]
  belongs_to :user
  has_and_belongs_to_many :facebook_statuses
  
  def get_statuses
    p "*** GET STATUSES"
    # Thread.new do
      # fb_auth = FacebookAuth.where(:user_id => self.user_id).first
      # access_token = prepare_access_token(fb_auth.app_id, fb_auth.app_secret, fb_auth.consumer_key)
      # # (0..7).to_a.reverse.each do |i|
        # # date = (Time.now - i.days).strftime("%Y-%m-%d")
        # # p "*** DATE: "+date.to_s
        # url = "https://graph.facebook.com/search?type=post&q="+URI::encode(self.query.gsub(/[\n ]+/,""))
        # p "*** URL: "+url
        # response = access_token.get(url)
        # response = JSON.parse(response.body)
        # p response
        # # response["statuses"].each do |status|
          # # fb_status = FacebookStatus.from_json(status)
          # # if !fb_status.blank? && !self.fb_statuses.include?(fb_status)
            # # self.fb_statuses << fb_status
          # # end
        # # end
        # # sleep(5)
      # # end
    # end
  end
  
  # def prepare_access_token(app_key, app_secret, oauth_consumer)
    # consumer = OAuth::Consumer.new(app_key, app_secret, { :site => "https://graph.facebook.com", :scheme => :header })
    # request_token = consumer.get_request_token
    # access_token = request_token.get_access_token
    # oauth_params = {:consumer => oauth_consumer, :token => access_token}
    # return OAuth::AccessToken.from_hash(consumer, oauth_params)
  # end
end
