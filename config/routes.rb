Rails.application.routes.draw do

  match "*all" => "application#cors_preflight_check", via:[ :options ]

  root 'welcome#apireference'

  scope '/api' do
    scope '/login' do
      get '/:oauth_token' => 'sessions#create'
    end
    scope '/users' do
      get '/' => 'users#index'
      scope '/:id' do
        get '/' => 'users#show'
        delete '/' => 'users#destroy'
        put '/' => 'users#update'
        put '/updateAdmin' => 'users#updateAdmin'
      end
    end
    delete '/logout' => 'sessions#destroy'
    get '/lists' => 'items#lists'
    get '/listsForUser/:uid' => 'items#lists_for_user'
    scope '/items' do
      get '/' => 'items#index'
      post '/' => 'items#create'
      get '/common/words' => 'items#most_common_words'
      get '/:term/search' => 'items#search'
      scope '/:id' do
        get '/' => 'items#show'
        get '/children' => 'items#children'
        get '/childrenForUser/:uid' => 'items#children_for_user'
        put '/' => 'items#update'
        delete '/' => 'items#destroy'
        delete '/archive' => 'items#archive'
        get '/solutions' => 'items#solutions'
        post '/mapSolution' => 'items#addLink'
        post '/unmapSolution' => 'items#removeLink'
      end
    end
    scope '/solutions' do
      get '/' => 'solutions#index'
      post '/' => 'solutions#create'
      scope '/:id' do
        get '/' => 'solutions#show'
        put '/' => 'solutions#update'
        delete '/' => 'solutions#destroy'
        get '/items' => 'solutions#items'
        post '/mapItem' => 'solutions#addLink'
        post '/like/:item_id' => 'solutions#like'
        post '/dislike/:item_id' => 'solutions#dislike'
        post '/view/:item_id' => 'solutions#view'
        post '/click/:item_id' => 'solutions#click'
        delete '/unmapItem/:item_id' => 'solutions#removeLink'
      end
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
