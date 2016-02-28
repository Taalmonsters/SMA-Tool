batch_size = 1000
0.step(TwitterStream.count, batch_size).each do |offset|
  TwitterStream.order(:id)
               .offset(offset)
               .limit(batch_size)
               .update_all(:status => :finished)
end
0.step(TwitterSearch.count, batch_size).each do |offset|
  TwitterSearch.order(:id)
               .offset(offset)
               .limit(batch_size)
               .update_all(:status => :finished)
end
0.step(TwitterIdSearch.count, batch_size).each do |offset|
  TwitterIdSearch.order(:id)
               .offset(offset)
               .limit(batch_size)
               .update_all(:status => :finished)
end
0.step(FacebookSearch.count, batch_size).each do |offset|
  FacebookSearch.order(:id)
               .offset(offset)
               .limit(batch_size)
               .update_all(:status => :finished)
end