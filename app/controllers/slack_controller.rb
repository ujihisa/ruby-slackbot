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
      File.unlink('/usr/bin/env') rescue nil
      File.unlink("/proc/#{$$}/environ") rescue nil
      case req['event']['type']
      when 'app_mention'
        Rails.logger.info("app_mention #{req.to_json}")
        allowed_channels = ['CPJDWPTJA', 'C015ZM53B40'].freeze
        channel = req['event']['channel']
        raise "Invalid channel: #{channel}" unless allowed_channels.include?(channel)

        text = req['event']['text'][/^<.*?> (.*)/, 1].to_s
        @binding ||= binding()
        msg =
          begin
            @binding.eval(text).inspect
          rescue => e
            e.inspect
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

  def post_slack(channel, msg)
    token = ENV['BOT_USER_OAUTH_ACCESS_TOKEN']
    Object.send(:remove_const, :ENV)

    self.class.define_method(:post_slack) do |channel, msg|
      msg = msg[...1000]
      system(
        'curl', '-H', "Authorization: Bearer #{token}",
        '-d', "channel=#{ERB::Util.url_encode(channel)}&text=#{ERB::Util.url_encode(msg)}", 'https://slack.com/api/chat.postMessage',
        exception: true)
    end
    post_slack(channel, msg)
  end

  def poison_pill
    Thread.start do
      sleep 5
      exit
    end
    render plain: "Ok, I'm going to die!"
  end
end
