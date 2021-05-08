# frozen_string_literal: true

class FakeSlackController < ApplicationController
  def get
  end

  def post
    r, w = IO.pipe
    system('curl', '-s', '-d', {
      type: 'event_callback',
      event: {
        type: 'app_mention',
        text: "<@a> #{params[:body]}",
        channel: 'CPJDWPTJA',
      }
    }.to_json, 'http://localhost:3000/slack/api', out: w)
    w.close

    flash[:reply] = JSON.parse(r.read)['posted_to_slack']
    respond_to do |format|
      format.html { redirect_to action: :get  }
    end
  end
end
