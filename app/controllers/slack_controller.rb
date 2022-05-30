# frozen_string_literal: true

class SlackController < ActionController::API
  BINDING = binding()

  def initialize
    super
    @recent_processed_messages = Set.new
    @@history ||= []
  end

  def api
    req = JSON.parse(request.body.read)
    if !req['type'] # via pub/sub
      req = JSON.parse(Base64.decode64(req.dig('message', 'data')))
    end

    case req['type']
    when 'url_verification'
      render plain: req['challenge']
    when 'event_callback'
      case req['event']['type']
      when 'app_mention'
        Rails.logger.info("app_mention #{req.to_json}")
        allowed_channels = [
          'CPJDWPTJA',
          'C015ZM53B40', # ruby-ja
          'C4VT738BU', # lunch-ja
          'CFSPNGYF4', # school-devs-ja
          'C50FYM9BL', # sre-ja
        ].freeze 
        channel = req['event']['channel']
        raise "Invalid channel: #{channel}" unless allowed_channels.include?(channel)

        client_msg_id = req['event']['client_msg_id']
        raise "Duplicated requests: #{client_msg_id}" if @recent_processed_messages.member?(client_msg_id)
        @recent_processed_messages << client_msg_id

        case req['event']['text'][/^<.*?> (.*)/, 1]
        in nil
          render json: { ok: true }
        in text
          text = CGI.unescapeHTML(text.to_s)
          result =
            begin
              result = BINDING.eval(text)
              @@history ||= []
              @@history << text
              result
            rescue Exception => e
              e
            end
          formatted_result =
            case result
            when Exception
              "ERROR: #{text.inspect} failed to evaluate.\n```#{e.class}: #{e.message}```"
            else
              result.inspect
            end
          post_slack(channel, formatted_result)
          render json: { ok: true, posted_to_slack: formatted_result }
        end
      else
        raise "What's this req: #{req.to_json}"
      end
    else
      raise "What's this req: #{req.to_json}"
    end
  end

  def post_slack(channel, msg)
    token = ENV['BOT_USER_OAUTH_ACCESS_TOKEN']

    self.class.define_method(:post_slack) do |channel, msg|
      msg = msg[...1000]
      unless Rails.env.test?
        res = HTTPClient.post(
          'https://slack.com/api/chat.postMessage',
          header: {
            Authorization: "Bearer #{token}",
          },
          body: {
            channel: channel,
            text: msg,
          },
        )
        if res.ok? && JSON.parse(res.content)['ok']
          # ok
        else
          raise "Failed with #{res.content}"
        end
      end
    end
    post_slack(channel, msg)
  end

  def history
    render json: @@history
  end

  def poison_pill
    Thread.start do
      sleep 5
      exit
    end
    render plain: "Ok, I'm going to die!"
  end
end
