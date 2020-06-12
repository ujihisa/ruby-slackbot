Rails.application.routes.draw do
  root 'home#index'

  post 'slack/api'
  get 'slack/poison_pill'
end
