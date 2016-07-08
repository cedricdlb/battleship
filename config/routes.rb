Rails.application.routes.draw do
  resources :games do
    patch 'join', on: :member
    resources :moves
  end
  resources :players
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
