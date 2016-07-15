Rails.application.routes.draw do
  # api
  namespace :api do
    namespace :v1 do
      resources :games do
        get   'status', on: :member
        patch 'join',   on: :member
        resources :moves
      end
      resources :players, only: [:index, :show, :create, :update, :destroy]
    end
  end

  # html/JS
  resources :games do
    get   'status', on: :member
    patch 'join',   on: :member
    resources :moves
  end
  resources :players
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
