Rails.application.routes.draw do
  resources :games do
    resources :moves
  end
  resources :players
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
