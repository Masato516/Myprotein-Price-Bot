require "sinatra"
 
require "json"
require "net/http"
require "uri"
require "tempfile"
 
require "line/bot"
 
def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end
 
def chat_bot_replies(a_question, user_name)
  if a_question.match?(/(Hi|Hey|Konnichiwa|Hi there|Hey there|Hello|Test).*/i)
    "Hey " + user_name + ", how are you?"
  elsif a_question.match?(/(Good Morning|Wake up|Morning).*/i)
    "Good morning"
  elsif a_question.match?(/(Good night|Sleep|Night|Evening).*/i)
    ["Sweet dreams, "+ user_name, "Good night!" + user_name].sample
  elsif a_question.match?(/how\s+.*are\s+.*you.*/i)
    "I am super!, " + user_name
  elsif a_question.end_with?('?')
    "Nice question, " + user_name + "!"
  else
    ["Really?!", "Great to hear that.", "Wow."].sample
  end
End
post "/callback" do
  body = request.body.read
 
  signature = request.env["HTTP_X_LINE_SIGNATURE"]
  unless client.validate_signature(body, signature)
    error 400 do "Bad Request" end
  end
 
  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        p event
        user_id = event["source"]["userId"]
        user_name = ""
 
        response = client.get_profile(user_id)
        case response
        when Net::HTTPSuccess then
          contact = JSON.parse(response.body)
          p contact
          user_name = contact["displayName"]
        else
          p "#{response.code} #{response.body}"
        end
 
        message = {
          type: "text",
          text: chat_bot_replies(event.message["text"], user_name)
        }
 
        client.reply_message(event["replyToken"], message)
 
        p 'One more message!'
        p event["replyToken"]
        p message
        p client
 
      else
          message = {
            type: "sticker",
            packageId: "11537",
            stickerId: ["52002742", "52002753", "52002745", "52002768"].sample
          }
 
          client.reply_message(event["replyToken"], message)
      end
    end
  }
 
  "OK"
end