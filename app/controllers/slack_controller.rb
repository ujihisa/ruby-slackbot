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
        Rails.logger.info("app_mention #{JSON.pretty_generate(req)}"
        render plain: { ok: true }
      else
        raise "What's this req: #{JSON.pretty_generate(req)}"
      end
    else
      raise "What's this req: #{JSON.pretty_generate(req)}"
    end
  end
end
