class SlackController < ActionController::API
  def initialize
    super
    @recent_processed_messages = Set.new
  end

  def api
    req = JSON.parse(request.body.read)

    case req['type']
    when 'url_verification'
      render plain: req['challenge']
    when 'event_callback'
      case req['event']['type']
      when 'app_mention'
        Rails.logger.info("app_mention #{req.to_json}")
        allowed_channels = ['CPJDWPTJA', 'C015ZM53B40', 'C4VT738BU'].freeze # ruby-ja, lunch-ja
        channel = req['event']['channel']
        raise "Invalid channel: #{channel}" unless allowed_channels.include?(channel)

        client_msg_id = req['event']['client_msg_id']
        raise "Duplicated requests: #{client_msg_id}" if @recent_processed_messages.member?(client_msg_id)
        @recent_processed_messages << client_msg_id

        text = req['event']['text'][/^<.*?> (.*)/, 1].to_s
        text = CGI.unescapeHTML(text)
        @@binding ||= binding()
        result =
          begin
            result = @@binding.eval(text)
            @@history ||= []
            @@history << text
            result
          rescue => e
            e
          end
        post_slack(channel, result.inspect)
        render json: { ok: true }
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
        system(
          'curl', '-s', '-H', "Authorization: Bearer #{token}",
          '-d', "channel=#{ERB::Util.url_encode(channel)}&text=#{ERB::Util.url_encode(msg)}", 'https://slack.com/api/chat.postMessage',
          exception: true)
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
