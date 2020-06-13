Rails.application.routes.draw do
  root 'home#index'

  post 'slack/api'
  get 'slack/history'
  get 'slack/poison_pill'
end
