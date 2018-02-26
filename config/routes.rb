Rails.application.routes.draw do
  resources :companies do
  	collection { post :import }
  end 	


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'index#index'
  get '/', to: 'index#index'
  # progress
  get 'start', to: 'progress#start'

  get 'parse', to: 'liqnet#parse'
  get 'upload', to: 'upload#index'

  # upload handler
  post 'import_inventory', to: 'upload#import'
  
  get 'show', to: 'upload#show'

  # api routes
  get '/api/i18n/:locale' => 'api#i18n'
end
