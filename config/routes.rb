require 'routes/api_constraints'

Rails.application.routes.draw do

  namespace :api do
    scope module: :v1, constraints: Routes::ApiConstraints.new(version: 1, default: true) do
      post '/caesar/guess',    to: 'caesar#make_guess'
      post '/caesar/encrypt/', to: 'caesar#crypt', defaults: { operation: :encrypt }
      post '/caesar/decrypt/', to: 'caesar#crypt', defaults: { operation: :decrypt }
    end

    # scope module: v2, constraints: Routes::ApiConstraints.new(version: 2) do
    #   post '/caesar/guess', to: 'caesar#make_guess'
    #   and so on...
    # end
  end

  scope module: :public do
    root 'index#index'
    get '*path', to: 'index#index'
  end

end
