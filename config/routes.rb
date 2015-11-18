Rails.application.routes.draw do

  get 'trade/:id_name', to: "trades#show"
  resources :trades, except:[:show] do
    post :execute, on: :member
  end
  get 'portfolio', to: 'portfolios#index'
  get 'not-logged-in', to: 'portfolios#not_logged_in'
  root to: "portfolios#index"
end
