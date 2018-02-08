Rails.application.routes.draw do

  devise_for :users

  root 'store#index'

  # Catch error conditions early.
  match '(errors)/:status', to: 'errors#show',
    constraints: {status: /\d{3}/},
    defaults: {status: '500'},
    via: :all

  # Point-of-sale interface.
  namespace :pos do
    root 'main#index'
    resources :orders do
      resources :order_items, shallow: true
    end
    resources :products do
      get :query, on: :collection
    end
  end

  resources :orders do
    resources :order_items, shallow: true
    get :duplicate, on: :member
    get :quote, on: :member
  end
  resource :profile, only: [:show, :edit, :update]

  # Catch bona fide storefront urls that are not accessible via slugs.
  get  '/store', to: 'store#index', as: :store
  get  '/store/lookup', to: 'store#lookup', as: :lookup
  get  '/cart/delete',  to: 'store#delete_cart', as: :delete_cart
  post '/correspondence/mail_form', to: 'correspondence#mail_form', as: :mail_form
  get '/delegate/:group_id', to: 'store#delegate', as: :delegate

  # Routes for the checkout process:
  #
  # 1) set order type
  post '/checkout/:order_id/order_type', to: 'checkout#order_type', as: :order_type
  # 2) enter checkout process
  get  '/checkout/:order_id', to: 'checkout#checkout',  as: :checkout
  # 3) select a shipping method
  get  '/checkout/:order_id/shipping_method/:method_id', to: 'checkout#shipping_method', as: :shipping_method
  # 4) create a shipment
  post '/checkout/:order_id/ship/:method_id', to: 'checkout#ship', as: :ship
  # 5) enter payment information
  get  '/checkout/:order_id/pay/:method', to: 'checkout#pay', as: :pay
  # 6) verify credit card payment or return from online payment
  post '/checkout/:order_id/verify', to: 'checkout#verify', as: :verify
  get  '/checkout/:order_id/return', to: 'checkout#return', as: :return
  # 6b) handle online payment notify if the user failed to return herself
  get  '/checkout/:order_id/notify', to: 'checkout#notify', as: :notify
  # 6c) confirm order when payment is not collected
  post '/checkout/:order_id/confirm', to: 'checkout#confirm', as: :confirm
  # 7) show a receipt
  get  '/checkout/:order_id/receipt', to: 'checkout#receipt', as: :receipt

  # Product specific routes.
  post '/product/:product_id/order', to: 'store#order_product', as: :order_product

  # Category, department, promotion, and product views.
  get '/category/:category_id', to: 'store#show_category', as: :show_category
  get '/department/:department_id', to: 'store#show_department', as: :show_department
  get '/promotion/:promotion_id', to: 'store#show_promotion', as: :show_promotion
  get '/product/:product_id(/:category_id)', to: 'store#show_product', as: :show_product

  # These routes can be reached via /:slug
  get '/front', to: 'store#front', as: :front
  get '/cart',  to: 'store#cart',  as: :cart

  # If we get here, the url is seen as a slug of a page. If the page
  # is internal, its slug will match one of the above routes.
  get '/:slug', to: 'store#show_page', as: :show_page, slug: /[a-z0-9_-]+/

  namespace :admin do
    get '/dashboard', to: 'dashboard#index', as: :dashboard

    get '/reports', to: 'reports#index', as: :reports
    get '/reports/inventory', to: 'reports#inventory', as: :inventory_report
    get '/reports/sales', to: 'reports#sales', as: :sales_report
    get '/reports/purchases', to: 'reports#purchases', as: :purchases_report

    resources :stores do
      resources :hostnames, shallow: true
      resources :images, shallow: true
      resource :style
    end
    resources :departments do
      resources :images, shallow: true
      post :reorder, on: :collection
    end
    resources :categories do
      resources :images, shallow: true
      post :rearrange, on: :collection
      get :reorder_products, on: :member
    end
    resources :pages do
      resources :images, shallow: true
      post :rearrange, on: :collection
      get :layout, on: :member
      resources :sections, shallow: true do
        resources :images
        resources :columns do
          resources :segments do
            resources :images
            resources :documents
            patch :modify, on: :member
            post :reorder, on: :collection
          end
        end
        post :reorder, on: :collection
      end
    end
    resources :albums do
      resources :images, shallow: true
    end
    resources :products do
      resources :images, shallow: true
      resources :documents, shallow: true
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
      collection do
        get :query
        post :reorder
        post :upload_file
      end
      member do
        post :add_requisite_entries
        post :duplicate
        patch :make_primary
      end
    end
    resources :promotions do
      resources :promoted_items, shallow: true
      resources :images, shallow: true
      post :add_products, on: :member
      post :add_categories, on: :member
    end
    resources :orders do
      resources :images, shallow: true
      resources :order_items, shallow: true
      member do
        get :forward
        get :quote
        patch :approve
        get :review
        patch :conclude
        post :add_products
      end
    end
    resources :properties do
      post :reorder, on: :collection
    end
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
    resources :customer_assets do
      resources :asset_entries, shallow: true, only: :create
    end
    resources :tax_categories do
      post :reorder, on: :collection
    end
    resources :inventories do
      post :reorder, on: :collection
    end
    resources :inventory_items do
      resources :inventory_entries, shallow: true, only: :create
    end
    resources :order_types
    resources :shipping_methods do
      resources :images, shallow: true
    end

    post '/hostnames/reorder', to: 'hostnames#reorder', as: :reorder_hostnames
    post '/images/reorder', to: 'images#reorder', as: :reorder_images
    post '/documents/reorder', to: 'documents#reorder', as: :reorder_documents
    post '/images/delete', to: 'images#delete', as: :delete_image
    post '/documents/delete', to: 'documents#delete', as: :delete_document
    post '/iframes/reorder', to: 'iframes#reorder', as: :reorder_iframes
  end
end
