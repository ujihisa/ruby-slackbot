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
          'CPJDWPTJA', # ruby-ja
          'C015ZM53B40',
          'C4VT738BU', # lunch-ja
          'CFSPNGYF4', # school-devs-ja
          'C50FYM9BL', # sre-ja
          'C044DUN1H9P', # k12-platform-enhancement-devs-ja -> k12-video-devs-ja
          'C044LCC36QH', # k12-auth-devs-ja
        ].freeze
        channel = req['event']['channel']
        raise "Invalid channel: #{channel}" unless allowed_channels.include?(channel)

        client_msg_id = req['event']['client_msg_id']
        raise "Duplicated requests: #{client_msg_id}" if @recent_processed_messages.member?(client_msg_id)
        @recent_processed_messages << client_msg_id

        case req['event']['text'][/^<.*?>\s*(.*)/m, 1]
        in nil
          render json: { ok: true }
        in text
          if /\b(sample|shuffle|send|public_send)\b/ =~ text && channel == 'CPJDWPTJA'
            if false
              formatted_result = "今週は#{$1}()以外を使ってみようキャンペーン実施中です:fufufu:\nhttps://rurema.clear-code.com/3.4/method/Array/i/#{$1}.html"
              post_slack(channel, formatted_result)
              render json: { ok: true, posted_to_slack: formatted_result }
              return
            end
          end

          text = CGI.unescapeHTML(text.to_s)
          result =
            begin
              result = BINDING.eval(text)
              @@history ||= []
              @@history << [:evaluated, text]
              result
            rescue Exception => e
              @@history ||= []
              @@history << [:rescued, text]
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
        res = Faraday.post(
          'https://slack.com/api/chat.postMessage',
          {
            channel: channel,
            text: msg,
          },
          {
            Authorization: "Bearer #{token}",
          },
        )
        if res.success? && JSON.parse(res.body)['ok']
          # ok
        else
          raise "Failed with #{res.body}"
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
