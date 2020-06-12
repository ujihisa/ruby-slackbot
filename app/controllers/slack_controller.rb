# Dirty hack
class ApplicationControllerApi < ActionController::API
end

class SlackController < ApplicationControllerApi
  def api
    req = JSON.parse(pp request.body.read)

    case req['type']
    when 'url_verification'
      render plain: req['challenge']
    when 'event_callback'
      case req['event']['type']
      when 'app_mention'
        Rails.logger.info("app_mention #{req.to_json}")
        allowed_channels = ['CPJDWPTJA', 'C015ZM53B40']
        channel = req['event']['channel']
        raise "Invalid channel: #{channel}" unless allowed_channels.include?(channel)

        text = req['event']['text'][/^<.*?> (.*)/, 1]
        @binding ||= binding()
        tap do
          (env, ENV) = [ENV, nil]
          msg = @binding.eval(text)
        ensure
          ENV = env
        end
        post_slack(channel, msg)
        render plain: { ok: true }
      else
        raise "What's this req: #{req.to_json}"
      end
    else
      raise "What's this req: #{req.to_json}"
    end
  end

  private def post_slack(channel, msg)
    system(
      'curl', '-H', "Authorization: Bearer #{ENV['BOT_USER_OAUTH_ACCESS_TOKEN']}",
      '-d', "channel=#{ERB::Util.url_encode(channel)}&text=#{ERB::Util.url_encode(msg)}", 'https://slack.com/api/chat.postMessage',
      exception: true)
  end
end
