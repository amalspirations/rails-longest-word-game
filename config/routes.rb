Rails.application.routes.draw do
  get '/', to: 'pages#game'

  get '/game', to: 'pages#game'

  post '/score', to: 'pages#score'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
