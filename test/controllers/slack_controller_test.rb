require 'test_helper'

class SlackControllerTest < ActionDispatch::IntegrationTest
  test '/slack/api with ignored message' do
    post('/slack/api', headers: { 'CONTENT_TYPE' => 'application/json' }, params: {
      'token' => 'ZZZZZZWSxiZZZ2yIvs3peJ',
      'team_id' => 'T061EG9R6',
      'api_app_id' => 'A0MDYCDME',
      'event' => {
        'type' => 'app_mention',
        'user' => 'W021FGA1Z',
        'text' => 'You can count on <@U0LAN0Z89> for an honorable mention.',
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

    assert_response :success
    response_json = JSON.parse(response.body)
    assert_equal(true, response_json['ok'])
    assert_nil(response_json['posted_to_slack'])
  end

  test '/slack/api with evaluating messages' do
    [
      ['<@ruby> 1 + 2', 3],
      ['<@ruby> "hello"', 'hello'],
      ['<@ruby> raise', ''],
    ].each do |text, expected_result|
      post('/slack/api', headers: { 'CONTENT_TYPE' => 'application/json' }, params: {
        'token' => 'ZZZZZZWSxiZZZ2yIvs3peJ',
        'team_id' => 'T061EG9R6',
        'api_app_id' => 'A0MDYCDME',
        'event' => {
          'type' => 'app_mention',
          'user' => 'W021FGA1Z',
          'text' => text,
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

      response_json = JSON.parse(response.body)
      assert_equal(expected_result, response_json['posted_to_slack'])
    end
  end
end
