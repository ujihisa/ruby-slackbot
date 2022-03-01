require 'test_helper'

class SlackTest < ActionDispatch::IntegrationTest
  test 'history grows' do
    get '/slack/history'
    current_history = JSON.parse(response.body)

    travel_to('2022-02-27T15:14:03-08:00') do
      p Time.new(2021, 3, 1, 0, 0, 0, 32400)
    end
    exit

    post('/slack/api', headers: { 'CONTENT_TYPE' => 'application/json' }, params: {
      'token' => 'ZZZZZZWSxiZZZ2yIvs3peJ',
      'team_id' => 'T061EG9R6',
      'api_app_id' => 'A0MDYCDME',
      'event' => {
        'type' => 'app_mention',
        'user' => 'W021FGA1Z',
        'text' => '<@ruby> 1 + 2',
        'ts' => '1515449483.000108',
        'channel' => 'CPJDWPTJA',
        'event_ts' => '1515449483000108'
      },
      'type' => 'event_callback',
      'event_id' => 'Ev0MDYHUEL',
      'event_time' => 1515449483000108,
      'authed_users' => [
        'U0LAN0Z89'
      ]
    }.to_json)
    assert_equal('3', JSON.parse(response.body)['posted_to_slack'])

    get '/slack/history'
    assert_equal(current_history + ['1 + 2'], JSON.parse(response.body))
  end
end
