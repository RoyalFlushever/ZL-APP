Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'index#index'
  get '/', to: 'index#index'

  get 'parse', to: 'liqnet#parse'
  get 'upload', to: 'upload#index'
  post 'import_inventory', to: 'upload#import'
  get 'show', to: 'upload#show'
end
