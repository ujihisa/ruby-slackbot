# Dirty hack
class ApplicationControllerApi < ActionController::API
end

class SlackController < ApplicationControllerApi
  def api
    req = JSON.parse(pp request.body.read)

    case req['type']
    when 'url_verification'
      render plain: req['challenge']
    else
      raise "What's this req: #{JSON.pretty_generate(req)}"
    end
  end
end
