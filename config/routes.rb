Rails.application.routes.draw do

  devise_for :users

  constraints(host: ENV['STELLAR_HOST']) do
    resource :onboarding do
      get :frontend
      get :backend
      get :admin
      post 'validate/:step', action: :validate, as: :validate
    end
    get '/', to: 'account#index'
    get '/get-started', to: 'account#onboarding', as: :get_started
  end

  root 'store#index'

  # Catch error conditions early.
  match '(errors)/:status', to: 'errors#show',
    constraints: {status: /\d{3}/},
    defaults: {status: '500'},
    via: :all

  # Point-of-sale interface.
  #namespace :pos do
  #  root 'main#index'
  #  resources :orders do
  #    resources :order_items, shallow: true
  #  end
  #  resources :products do
  #    get :query, on: :collection
  #  end
  #end

  # Mount stripe engine at /stripe
  mount Stripe::Engine => '/stripe'

  resources :orders do
    resources :order_items, shallow: true
    member do
      get :select
      get :preview
      patch :claim
      get :duplicate
    end
  end
  resource :profile, only: [:show, :edit, :update]

  # Catch bona fide storefront urls that are not accessible via slugs.
  get  '/store', to: 'store#index', as: :store
  get  '/store/lookup', to: 'store#lookup', as: :lookup
  get  '/cart/quote/:recipient', to: 'store#quote', as: :send_quote
  get  '/cart/delete',  to: 'store#delete_cart', as: :delete_cart
  post '/cart/activate_code', to: 'store#activate_code', as: :activate_code
  post '/correspondence/mail_form', to: 'correspondence#mail_form', as: :mail_form

  # Routes for the checkout process:
  #
  # 1) set order type
  post '/checkout/:order_id/order_type', to: 'checkout#order_type', as: :order_type
  # 2) enter checkout process
  get  '/checkout/:order_id', to: 'checkout#checkout',  as: :checkout
  # 3) select a shipping method
  get  '/checkout/:order_id/shipping_method/:method_id', to: 'checkout#shipping_method', as: :shipping_method
  # 4) create a shipment
  post '/checkout/:order_id/ship', to: 'checkout#ship', as: :ship
  # 5) get payment methods
  get  '/checkout/:order_id/payment_methods', to: 'checkout#payment_methods', as: :payment_methods
  # 6) enter payment information
  get  '/checkout/:order_id/pay/:method', to: 'checkout#pay', as: :pay
  # 7) verify credit card payment or return from online payment
  post '/checkout/:order_id/verify', to: 'checkout#verify', as: :verify
  get  '/checkout/:order_id/return', to: 'checkout#return', as: :return
  # 7b) handle online payment notify if the user failed to return herself
  get  '/checkout/:order_id/notify', to: 'checkout#notify', as: :notify
  # 7c) confirm order when payment is not collected
  post '/checkout/:order_id/confirm', to: 'checkout#confirm', as: :confirm
  # 8) show a receipt
  get  '/checkout/:order_id/receipt', to: 'checkout#receipt', as: :receipt

  # Product specific routes.
  post '/product/:product_id/order', to: 'store#order_product', as: :order_product
  post '/product/:product_id/set_order_amount', to: 'store#set_order_amount', as: :set_order_amount

  # Favorite manipulation.
  get    '/store/favorites', to: 'store#show_favorites', as: :favorites
  get    '/store/favorites/:product_id', to: 'store#show_favorite', as: :show_favorite
  post   '/store/favorites/:product_id', to: 'store#add_favorite', as: :add_favorite
  delete '/store/favorites/:product_id', to: 'store#remove_favorite', as: :remove_favorite

  # Category, tag, department, promotion, and product views.
  get '/category/:category_id', to: 'store#show_category', as: :show_category
  get '/category/:category_id/order', to: 'store#show_category_order', as: :show_category_order
  get '/tag/:tag_id', to: 'store#show_tag', as: :show_tag
  get '/department/:department_id', to: 'store#show_department', as: :show_department
  get '/promotion/:promotion_id', to: 'store#show_promotion', as: :show_promotion
  get '/product/:product_id(/:category_id)', to: 'store#show_product', as: :show_product
  get '/products/promoted', to: 'store#show_promoted_products', as: :show_promoted_products

  # These routes can be reached via /:slug
  get '/front', to: 'store#front', as: :front
  get '/cart',  to: 'store#cart',  as: :cart

  # Content consumer actions.
  get '/content/feed', to: 'content#feed', as: :content_feed

  # Koala actions
  get 'koala/feed'

  # If we get here, the url is seen as a slug of a page. If the page
  # is internal, its slug will match one of the above routes.
  get '/:slug', to: 'store#show_page', as: :show_page, slug: /[a-z0-9_-]+/

  namespace :admin do
    get '/dashboard', to: 'dashboard#index', as: :dashboard

    get '/reports', to: 'reports#index', as: :reports
    get '/reports/inventory', to: 'reports#inventory', as: :inventory_report
    get '/reports/sales', to: 'reports#sales', as: :sales_report
    get '/reports/sales_tax', to: 'reports#sales_tax', as: :sales_tax_report
    get '/reports/purchases', to: 'reports#purchases', as: :purchases_report
    get '/reports/product/:product_id/sales', to: 'reports#product_sales', as: :product_sales

    resources :stores do
      resources :hostnames, shallow: true
      resources :pictures, shallow: true
      resource :style
    end
    resources :subscriptions
    resources :groups do
      resources :users, only: [:index, :new, :create] do
        patch :join, on: :member
      end
      member do
        patch :make_default
        get :select_categories
        patch :toggle_category
      end
      post :reorder, on: :collection
    end
    resources :users, except: [:index, :new, :create] do
      resources :roles, only: [] do
        patch :toggle, on: :member
      end
    end
    resources :policies do
      patch :accept, on: :member
    end
    resources :tax_categories do
      post :reorder, on: :collection
    end
    resources :inventories do
      post :reorder, on: :collection
    end
    resources :inventory_items do
      resources :inventory_entries, shallow: true, only: :create
      collection do
        get :query
        get :refresh
      end
    end
    resources :inventory_checks do
      resources :inventory_check_items, shallow: true do
        member do
          patch :approve
          patch :discard
        end
      end
      member do
        patch :complete
        get :resolve
        patch :conclude
      end
    end
    resources :properties do
      post :reorder, on: :collection
    end
    resources :tags do
      resources :pictures, shallow: true
    end
    resources :transfers do
      resources :transfer_items, shallow: true
      patch :complete, on: :member
    end
    resources :activities, only: [:index, :show] do
      get :context, on: :collection
    end
    resources :departments do
      resources :pictures, shallow: true
      post :reorder, on: :collection
    end
    resources :categories do
      resources :pictures, shallow: true
      post :rearrange, on: :collection
      get :reorder_products, on: :member
    end
    resources :pages do
      resources :pictures, shallow: true
      resources :sections, shallow: true do
        resources :pictures
        resources :columns do
          resources :pictures
          resources :segments do
            resources :pictures
            resources :documents
            member do
              get :settings
              patch :modify
              get :copy
            end
            collection do
              post :reorder
              post :paste
            end
          end
          member do
            get :settings
            patch :modify
          end
        end
        member do
          get :preload
          get :settings
          patch :modify
        end
        post :reorder, on: :collection
      end
      member do
        get :layout
        post :duplicate
      end
      post :rearrange, on: :collection
    end
    resources :images do
      get :select, on: :member
    end
    resources :products do
      resources :pictures, shallow: true
      resources :documents, shallow: true
      resources :product_properties, shallow: true
      resources :alternate_prices
      resources :iframes, shallow: true
      resources :inventory_items, shallow: true
      resources :component_entries, shallow: true do
        post :reorder, on: :collection
      end
      resources :requisite_entries, shallow: true do
        post :reorder, on: :collection
      end
      collection do
        get :query
        get 'pricing(/:group_id)', action: :pricing, as: :pricing
        post :reorder
        post :upload_file
      end
      member do
        post :add_requisite_entries
        post :duplicate
        patch 'set_price(/:group_id)', action: :set_price, as: :set_price
        patch :make_primary
      end
    end
    resources :promotions do
      resources :promoted_items, shallow: true
      resources :pictures, shallow: true
      post :add_products, on: :member
      post :add_categories, on: :member
    end
    resources :order_types
    resources :shipping_methods do
      resources :pictures, shallow: true
    end
    resources :orders do
      resources :pictures, shallow: true
      resources :order_items, shallow: true, except: [:index]
      resources :shipments, shallow: true do
        member do
          patch :refresh
          patch :complete
          get :label
        end
      end
      collection do
        get :incoming
        get :outgoing
      end
      member do
        get :forward
        get :preview
        patch :approve
        get :review
        patch :conclude
      end
    end
    resources :order_items, only: [:index]

    post '/hostnames/reorder', to: 'hostnames#reorder', as: :reorder_hostnames
    post '/pictures/reorder', to: 'pictures#reorder', as: :reorder_pictures
    post '/documents/reorder', to: 'documents#reorder', as: :reorder_documents
    post '/pictures/delete', to: 'pictures#delete', as: :delete_picture
    post '/documents/delete', to: 'documents#delete', as: :delete_document
    post '/iframes/reorder', to: 'iframes#reorder', as: :reorder_iframes
  end

  if Rails.env.production?
    match "*any", via: :all, to: redirect('/404')
  end
end
