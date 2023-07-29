# frozen_string_literal: true

class FakeSlackController < ApplicationController
  def get
  end

  def post
    r = Faraday.new(header: 'Content-type:application/json').post(
      'http://localhost:3000/slack/api',
      {
        type: 'event_callback',
        event: {
          type: 'app_mention',
          text: "<@a> #{params[:body]}",
          channel: 'CPJDWPTJA',
        }
      }
    )

    flash[:reply] = JSON.parse(r.body)['posted_to_slack']
    respond_to do |format|
      format.html { redirect_to action: :get  }
    end
  end
end
