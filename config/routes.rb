Rails.application.routes.draw do

  root 'store#index'

  # Redirect old /store route.
  get '/store', to: redirect('/front')

  # Redirect old product urls still found in the wild.
  get '/category/:category_id/product/:product_id',
    to: redirect('/product/:category_id/:product_id')

  resources :orders do
    get 'confirm', on: :member
    get 'duplicate', on: :member
    resources :order_items, shallow: true
  end

  devise_for :users

  # Catch bona fide storefront urls that are not accessible via slugs.
  get '/store/search',   to: 'store#search',    as: :search
  get '/store/checkout', to: 'store#checkout',  as: :checkout
  post '/order/confirm', to: 'store#confirm',   as: :confirm
  post '/correspondence/mail_form', to: 'correspondence#mail_form',
    as: :mail_form

  # Category and product views.
  get '/category/:category_id', to: 'store#show_category',
    as: :show_category
  get '/product/:category_id/:product_id', to: 'store#show_product',
    as: :show_product
  post '/product/:product_id/order', to: 'store#order_product',
    as: :order_product

  # These routes can be reached via /:slug
  get '/front', to: 'store#front', as: :front
  get '/cart',  to: 'store#cart',  as: :cart

  # If we get here, the url is seen as a slug of a page. If the page
  # is internal, its slug will match one of the above routes.
  get '/:slug', to: 'store#show_page', as: :show_page, slug: /[a-z0-9_-]+/

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
