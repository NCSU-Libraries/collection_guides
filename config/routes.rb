CollectionGuides::Application.routes.draw do

  devise_for :users

  # config/routes.rb
  resque_web_constraint = lambda do |request|
    Rails.env == 'development' || request.env['warden'].user
    # current_user.present? && current_user.respond_to?(:is_admin?) && current_user.is_admin?
  end

  constraints resque_web_constraint do
    mount ResqueWeb::Engine => "/resque_web"
  end

  get 'resources/index'
  get 'resources/show'
  get 'search/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'application#index'

  get 'help' => 'application#help', as: 'help'
  get 'sitemap(.:format)' => 'application#sitemap'
  get 'ead(.:format)' => 'ead#index'
  get 'ead3(.:format)' => 'ead#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  get 'search(.:format)' => 'search#index', as: 'searches'
  get 'resources(.:format)' => 'search#index', defaults: { all_resources: true }
  get 'resources/:id/ead' => 'ead#show'
  get 'resources/:id(/:tab)' => 'resources#show'

  get 'archival_objects/batch(.:format)' => 'archival_objects#batch_html'
  get 'archival_objects/:id(.:format)' => 'archival_objects#show'

  get 'filesystem_browser/:volume_id' => 'filesystem_browser#show'

  get ':eadid(.:format)' => 'resources#show', eadid: /[a-zA-Z\d_]+/
  get ':eadid/ead' => 'ead#show', eadid: /[a-zA-Z\d_]+/
  get ':eadid(/:tab)' => 'resources#show', eadid: /[a-zA-Z\d_]+/

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

  # for specs
  if Rails.env == 'test'
    get "resources/index" => "resources#index"
    get "resources/show" => "resources#show"
    get "archival_objects/show" => "archival_objects#show"
    get "archival_objects/batch_html" => "archival_objects#batch_html"
  end

  get '404', :to => 'application#not_found'
  get '*path', :to => 'application#not_found'

end
