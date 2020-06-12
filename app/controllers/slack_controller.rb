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
        channel = req['event']['channel']
        text = req['event']['text'][/^<.*?> (.*)/, 1]
        post_slack(channel, text)
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
      '-d', "channel=#{channel}&text=#{msg}", 'https://slack.com/api/chat.postMessage',
      exception: true)
  end
end
