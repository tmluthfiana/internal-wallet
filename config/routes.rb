Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'auth/sign_in', to: 'authentication#sign_in'
      get 'auth/refresh_token', to: 'authentication#refresh_token'

      resources :transactions, only: [:index] do
        collection do
          post 'deposit'
          post 'withdraw'
          post 'transfer'
        end
      end

      resources :stocks, only: [] do
        collection do
          get 'price_all'
          get 'price'
        end
      end
    end
  end
end
