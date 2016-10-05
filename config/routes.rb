Rails.application.routes.draw do

  # Portal landing page.
  root 'portal#index'

  # Catch error conditions early.
  match '(errors)/:status', to: 'errors#show',
    constraints: {status: /\d{3}/},
    defaults: {status: '500'},
    via: :all

  # Redirect old product urls still found in the wild.
  get '/category/:category_id/product/:product_id',
    to: redirect('/product/:category_id/:product_id')

  resources :orders do
    resources :order_items, shallow: true
    get :duplicate, on: :member
    get :quote, on: :member
  end

  devise_for :users

  # Portal routes.
  get '/department/:department_id', to: 'portal#show_department', as: :show_department
  get '/portal/search', to: 'portal#search', as: :portal_search

  # Catch bona fide storefront urls that are not accessible via slugs.
  get  '/store', to: 'store#index', as: :store
  get  '/store/search', to: 'store#search', as: :search
  get  '/store/lookup', to: 'store#lookup', as: :lookup
  get  '/store/pricing/(:pricing_group_id)', to: 'store#pricing', as: :pricing
  get  '/cart/delete',  to: 'store#delete_cart', as: :delete_cart
  post '/correspondence/mail_form', to: 'correspondence#mail_form',
    as: :mail_form

  # Routes for the checkout process:
  #
  # 1) select a shipping method
  get  '/checkout/:order_id/shipping_method/:method_id', to: 'checkout#shipping_method', as: :shipping_method
  # 2) create a shipment
  post '/checkout/:order_id/ship/:method_id', to: 'checkout#ship', as: :ship
  # 3) enter payment information
  get  '/checkout/:order_id/pay/:method', to: 'checkout#pay', as: :pay
  # 4) verify credit card payment or return from online payment
  post '/checkout/:order_id/verify', to: 'checkout#verify', as: :verify
  get  '/checkout/:order_id/return', to: 'checkout#return', as: :return
  # 5) confirm order
  post '/checkout/:order_id/confirm', to: 'checkout#confirm', as: :confirm
  # 6) show a receipt
  get  '/checkout/:order_id/receipt', to: 'checkout#receipt', as: :receipt

  get  '/checkout/:order_id/:order_type_id', to: 'checkout#checkout',  as: :checkout

  # Snippets
  get '/snippets/:type/:id', to: 'snippets#show', as: :show_snippet

  # Product specific routes.
  post '/product/:product_id/order', to: 'store#order_product', as: :order_product

  # Category and product views.
  get '/category/:category_id', to: 'store#show_category', as: :show_category
  get '/product/:category_id/:product_id', to: 'store#show_product', as: :show_product

  # These routes can be reached via /:slug
  get '/front', to: 'store#front', as: :front
  get '/cart',  to: 'store#cart',  as: :cart

  # If we get here, the url is seen as a slug of a page. If the page
  # is internal, its slug will match one of the above routes.
  get '/:slug', to: 'store#show_page', as: :show_page, slug: /[a-z0-9_-]+/

  namespace :admin do
    get '/dashboard', to: 'dashboard#index', as: :dashboard

    get '/reports', to: 'reports#index', as: :reports

    resources :portals do
      resources :images, shallow: true
    end
    resources :departments do
      post :reorder, on: :collection
    end
    resources :stores do
      resources :images, shallow: true
    end
    resources :categories do
      resources :images, shallow: true
      post :reorder, on: :collection
      get :reorder_products, on: :member
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
      resources :product_properties, shallow: true
      resources :alternate_prices, shallow: true
      resources :iframes, shallow: true
      resources :inventory_items, shallow: true
      resources :component_entries, shallow: true do
        post :reorder, on: :collection
      end
      resources :requisite_entries, shallow: true do
        post :reorder, on: :collection
      end
      get :query, on: :collection
      post :add_requisite_entries, on: :member
      post :duplicate, on: :member
      post :reorder, on: :collection
      post :upload_file, on: :collection
    end
    resources :promotions do
      resources :promoted_items, shallow: true
      post :add_products, on: :member
      post :add_categories, on: :member
    end
    resources :orders do
      resources :images, shallow: true
      resources :order_items, shallow: true
      get :forward, on: :member
      get :quote, on: :member
      post :add_products, on: :member
    end
    resources :properties do
      post :reorder, on: :collection
    end
    resources :users
    resources :customer_assets do
      resources :asset_entries, shallow: true, only: :create
    end
    resources :pricing_groups
    resources :tax_categories do
      post :reorder, on: :collection
    end
    resources :inventories
    resources :inventory_items do
      resources :inventory_entries, shallow: true, only: :create
    end
    resources :shipping_methods

    post '/images/reorder', to: 'images#reorder', as: :reorder_images
    post '/images/delete', to: 'images#delete', as: :delete_image
    post '/iframes/reorder', to: 'iframes#reorder', as: :reorder_iframes
  end
end
