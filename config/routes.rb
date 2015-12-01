Rails.application.routes.draw do

  devise_for :users

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'pages#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  get 'page/:id' => 'pages#show', as: :show_page

  get '/store' => 'store#index', as: :store
  get '/search' => 'store#search', as: :search
  get '/category/:category_id' => 'store#show_category', as: :show_category
  get '/category/:category_id/product/:product_id' => 'store#show_product', as: :show_product
  post '/product/:product_id/order' => 'store#order_product', as: :order_product

  get '/cart' => 'store#show_cart', as: :show_cart
  get '/checkout' => 'store#checkout', as: :checkout
  post '/confirm' => 'store#confirm', as: :confirm

  post '/correspondence/mail_form' => 'correspondence#mail_form', as: :mail_form

  resources :orders do
    get 'confirm', on: :member
    resources :order_items, shallow: true
  end

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

  namespace :admin do
    get '/dashboard' => 'dashboard#index', as: :dashboard

    resources :stores do
      resources :images, shallow: true
    end
    resources :categories do
      resources :images, shallow: true
      post :reorder, on: :collection
    end
    resources :custom_attributes do
      resources :custom_values, shallow: true
    end
    resources :pages do
      resources :images, shallow: true
      post :reorder, on: :collection
    end
    resources :products do
      resources :images, shallow: true
      resources :customizations, shallow: true
      resources :product_properties, shallow: true
      resources :iframes, shallow: true
      post :reorder, on: :collection
    end
    resources :promotions do
      resources :promoted_items, shallow: true
      post :add_products, on: :member
      post :add_categories, on: :member
    end
    resources :orders do
      resources :images, shallow: true
      resources :order_items, shallow: true
    end
    resources :properties do
      post :reorder, on: :collection
    end
    resources :users

    post '/custom_values/reorder' => 'custom_values#reorder', as: :reorder_custom_values
    post '/images/reorder' => 'images#reorder', as: :reorder_images
    post '/images/delete' => 'images#delete', as: :delete_image
    post '/iframes/reorder' => 'iframes#reorder', as: :reorder_iframes
  end


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
