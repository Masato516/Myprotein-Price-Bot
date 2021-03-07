# app.rb
require 'sinatra'
require 'line/bot'

def template
  {
    "type": "template",
    "altText": "位置検索中",
    "template": {
        "type": "buttons",
        "title": "最寄駅探索探索",
        "text": "現在の位置を送信しますか？",
        "actions": [
            {
              "type": "uri",
              "label": "位置を送る",
              "uri": "line://nv/location"
            }
        ]
    }
  }
end

def stations(longitude, latitude)
  uri = URI("http://express.heartrails.com/api/json")
  uri.query = URI.encode_www_form({
  method: "getStations",
    x: longitude,
    y: latitude
  })
  res = Net::HTTP.get_response(uri)
  JSON.parse(res.body)["response"]["station"]
end

def client
  @client ||= Line::Bot::Client.new { |config|
    p config.channel_id = ENV["LINE_CHANNEL_ID"]
    p config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    p config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each do |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          text: event.message['text']
        }
        if event.message['text'] =~ /おみくじ/
          message[:text] = %w(大吉 中吉 小吉 凶 大凶).shuffle.first
          client.reply_message(event['replyToken'], message)
        elsif event.message['text'] =~ /駅/
          client.reply_message(event['replyToken'], template)
        end
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      when Line::Bot::Event::MessageType::Location
        p event["message"]["latitude"]
        p event["message"]["longitude"]
        # APIを呼び出す関数です
        p stations = stations(event["message"]["longitude"], event["message"]["latitude"])
        p message = stations.map{|station|
          "#{station["name"]}駅 >> #{station["line"]}"
        }.join("\n")
        client.reply_message(event['replyToken'],{ type: 'text', text: message })
      end
    end
  end

  # Don't forget to return a successful response
  "OK"
end

# プッシュ通知
message = {
  type: 'text',
  text: price
}
response = client.push_message(ENV["LINE_USER_ID"], message)
p response