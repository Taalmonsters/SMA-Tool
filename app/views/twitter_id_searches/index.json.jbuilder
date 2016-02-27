json.array!(@twitter_id_searches) do |twitter_id_search|
  json.extract! twitter_id_search, :id
  json.url twitter_id_search_url(twitter_id_search, format: :json)
end
