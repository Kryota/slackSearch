require "slack"
require "json"
require "net/http"
require "uri"
require "dotenv"

# .envファイルから環境変数を読み込む
Dotenv.load

Slack.configure do |config|
  config.token = ENV["TOKEN"]
end

# これで指定したチャンネルの投稿を取得できる
messages = Slack.channels_history(channel: ENV["CHANNEL_ID"])['messages']

messageArray = messages.map do |message|
  messageHash = {}
  messageHash["id"] = message["client_msg_id"]
  messageHash["type"] = message["type"]
  messageHash["ts"] = message["ts"]
  messageHash["user"] = message["user"]
  messageHash["text"] = message["text"]

  messageHash
end

uri = URI.parse("http://localhost:8983/solr/slackCore/update?commit=true")
http = Net::HTTP.new(uri.host, uri.port)
req = Net::HTTP::Post.new(uri.request_uri)
req["Content-Type"] = "text/json; charset=utf-8"
req.body = messageArray.to_json

# puts req.body
res = http.request(req)

puts res.code, res.msg, res.body