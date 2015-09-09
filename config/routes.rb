ActionController::Routing::Routes.draw do |map|
  map.connect '/test', :controller => "web", :action => "test"

  map.resources :reviews, :collection => {:desire_new => :get}
  map.resources :baskets, :collection => {:add_to => :post, 
                                          :remove => [:post, :get], 
                                          :increase => [:post, :get], 
                                          :decrease => [:post, :get],
                                          :user => :get,
                                          :switch_user => :post,
                                          :set_user => [:get, :post],
                                          :set_promotional_code => :post,
                                          :begin_checkout => :post,
                                          :delivery => :get,
                                          :delivery_shipping => :get,
                                          :set_delivery => :put,
                                          :change_billing_address => :post,
                                          :change_delivery_address => :post,
                                          :gift_wrap => :get,
                                          :payment => :get,
                                          :google_reply => [:get, :post],
                                          :paypal_reply => [:get, :post],
                                          :paymentsense_reply => [:get, :post],
                                          :admin_payment => :post,
                                          :return => [:get, :post],
                                          :cheque => :post,
                                          :confirm_cheque => :post
                                          },
                          :member => {:set_delivery => :put,
                                      :set_gift_wrap => :put}
  map.basket 'basket', :controller => 'baskets'
  map.resources :addresses
  map.resources :promo_codes
  map.resources :price_ranges
  map.shipping_options "shipping_options", :controller => "shipping_options", :action => "index" 
  map.user_login 'user_login', :controller => 'user_sessions', :action => 'new'
  map.user_logout 'user_logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :user_password_resets
  map.resources :user_sessions
  map.resources :users
  map.resources :products, :member => {:get_option_2s => :post, :get_option_3s => :post, :reviews => :get}
  map.resources :variations
  map.customer_login 'customer_login', :controller => 'customer_sessions', :action => 'new'
  map.customer_logout 'customer_logout', :controller => 'customer_sessions', :action => 'destroy'
  map.resources :customer_sessions
  map.resources :customers
  map.resources :articles
  map.resources :page_nodes, :as => "page"
  map.resources :page_contents

  map.namespace :admin do |admin|

    admin.resources :feedbacks, :except => [:show]
    admin.resources :reviews, :except => [:show], :collection => {:update_name => :post}
    admin.resources :baskets, :member => {:convert_to_order => :get, :keep => :get}
    admin.resources :users, :except => [:show]
    admin.resources :products, :except => [:show], :collection => {:order => :post}
    admin.resources :variations, :except => [:show], :collection => {:update_stock => :post}
    admin.resources :customers, :except => [:show]
    admin.resources :articles, :except => [:show]
    admin.resources :page_nodes, :except => [:show],
                                 :collection => { :index_list => :get,
                                                  :index_list_advanced => :get,
                                                  :index_reorder => :get,
                                                  :order => :post},
                                 :member => {:branch => :get,
                                             :activate => :get,
  	                                         :toggle_display => :get}
    admin.resources :jargons, :except => [:show]
    admin.resources :newsletter_subscribers, :except => [:show]
    admin.resources :promo_codes, :except => [:show]
    admin.resources :price_ranges, :except => [:show]
    admin.resources :shipping_options, :except => [:show], :collection => {:order => :post}
    admin.resources :order_items, :except => [:show]
    admin.resources :orders, :except => [:show], :member => {:ship => :get, :cancel => :get, :invoice => :get, :cheque_paid => :get}
   
      
    admin.connect 'recycle_bin/index', :controller => 'recycle_bin', :action => 'index'
    
    admin.connect 'administrators/edit_self', :controller => 'administrators', :action => 'edit_self'
    
    # This route is not good and is what we are trying to move away from. It should be replaceable
    # when the new (as of October 2010) document uploader is finished and added to the site.
    admin.connect 'html_popups/:action', :controller => 'html_popups'
  end
  
  map.check 'check', :controller => 'web', :action => 'check'

  map.connect 'web/accessibility', :controller => 'web', :action => 'accessibility'
  map.connect 'web/contact_us', :controller => 'web', :action => 'contact_us'
  map.connect 'web/deliver_contact_us', :controller => 'web', :action => 'deliver_contact_us'
  map.connect 'web/index', :controller => 'web', :action => 'index'
  map.connect 'web/site_down', :controller => 'web', :action => 'site_down'
  map.connect 'web/site_map', :controller => 'web', :action => 'site_map'
  map.connect 'web/site_search', :controller => 'web', :action => 'site_search'  
  map.connect 'web/thank_you', :controller => 'web', :action => 'thank_you'
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
  map.root :controller => "web", :action => "index"
end
