Rails.application.routes.draw do
  root 'home#index'

  post 'slack/api'
end
