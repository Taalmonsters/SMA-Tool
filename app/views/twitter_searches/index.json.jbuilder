json.array!(@twitter_searches) do |twitter_search|
  json.extract! twitter_search, :id
  json.url twitter_search_url(twitter_search, format: :json)
end
