json.array!(@facebook_searches) do |facebook_search|
  json.extract! facebook_search, :id
  json.url facebook_search_url(facebook_search, format: :json)
end
