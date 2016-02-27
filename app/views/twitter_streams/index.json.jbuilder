json.array!(@twitter_streams) do |twitter_stream|
  json.extract! twitter_stream, :id
  json.url twitter_stream_url(twitter_stream, format: :json)
end
