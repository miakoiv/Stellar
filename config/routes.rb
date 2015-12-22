Rails.application.routes.draw do

  root 'store#first_page'

  devise_for :users

  get '/store', to: 'store#index', as: :store
  get '/search', to: 'store#search', as: :search

  get '/category/:category_id', to: 'store#show_category', as: :show_category
  get '/category/:category_id/product/:product_id', to: 'store#show_product', as: :show_product
  post '/product/:product_id/order', to: 'store#order_product', as: :order_product
  get '/page/index', to: 'store#first_page', as: :first_page
  get '/page/:page_id', to: 'store#show_page', as: :show_page

  get '/cart', to: 'store#show_cart', as: :show_cart
  get '/checkout', to: 'store#checkout', as: :checkout
  post '/confirm', to: 'store#confirm', as: :confirm

  post '/correspondence/mail_form', to: 'correspondence#mail_form', as: :mail_form

  resources :orders do
    get 'confirm', on: :member
    get 'duplicate', on: :member
    resources :order_items, shallow: true
  end

  namespace :admin do
    get '/dashboard', to: 'dashboard#index', as: :dashboard

    resources :stores do
      resources :images, shallow: true
    end
    resources :categories do
      resources :images, shallow: true
      post :reorder, on: :collection
      get :reorder_products, on: :member
    end
    resources :custom_attributes do
      resources :custom_values, shallow: true
    end
    resources :pages do
      resources :images, shallow: true
      post :reorder, on: :collection
    end
    resources :albums do
      resources :images, shallow: true
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

    post '/custom_values/reorder', to: 'custom_values#reorder', as: :reorder_custom_values
    post '/images/reorder', to: 'images#reorder', as: :reorder_images
    post '/images/delete', to: 'images#delete', as: :delete_image
    post '/iframes/reorder', to: 'iframes#reorder', as: :reorder_iframes
  end

  # Error conditions
  match '(errors)/:status', to: 'errors#show',
    constraints: {status: /\d{3}/},
    defaults: {status: '500'},
    via: :all
end
