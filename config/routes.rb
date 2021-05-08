Rails.application.routes.draw do
  root 'home#index'

  post 'slack/api'
  get 'slack/history'
  get 'slack/poison_pill'

  if Rails.env.development?
    get 'fake_slack', to: 'fake_slack#get'
    post 'fake_slack', to: 'fake_slack#post'
  end
end
