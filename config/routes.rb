Rails.application.routes.draw do
  root to:"disavows#index"

  get "/test", to:"disavows#test"

  get "/disavows/search", to:"disavows#search", as:"search"
  
  get "/disavows/new/:id", to:"disavows#new", as: 'add'

  post "/disavows/new/", to:"disavows#create"

  get "/disavows/:id", to:"disavows#show", as: 'show'

  post "/disavows/search_result", to:"disavows#search_result"

  get "/disavows/:id/destroy", to:"disavows#destroy"

end