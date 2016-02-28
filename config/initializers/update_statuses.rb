begin
  ActiveRecord::Base.connection
  batch_size = 1000
  if ActiveRecord::Base.connection.table_exists? 'twitter_streams'
    0.step(TwitterStream.count, batch_size).each do |offset|
      TwitterStream.order(:id)
                   .offset(offset)
                   .limit(batch_size)
                   .update_all(:status => 2)
    end
  end
  if ActiveRecord::Base.connection.table_exists? 'twitter_searches'
    0.step(TwitterSearch.count, batch_size).each do |offset|
      TwitterSearch.order(:id)
                   .offset(offset)
                   .limit(batch_size)
                   .update_all(:status => 2)
    end
  end
  if ActiveRecord::Base.connection.table_exists? 'twitter_id_searches'
    0.step(TwitterIdSearch.count, batch_size).each do |offset|
      TwitterIdSearch.order(:id)
                   .offset(offset)
                   .limit(batch_size)
                   .update_all(:status => 2)
    end
  end
  if ActiveRecord::Base.connection.table_exists? 'facebook_searches'
    0.step(FacebookSearch.count, batch_size).each do |offset|
      FacebookSearch.order(:id)
                   .offset(offset)
                   .limit(batch_size)
                   .update_all(:status => 2)
    end
  end
rescue ActiveRecord::NoDatabaseError
  
end