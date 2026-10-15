Rails.application.routes.draw do
  devise_for :admins, skip: [ :registrations ], controllers: {
    sessions: "admin/sessions", passwords: "admin/passwords"
  }, path: "", path_names: {
    sign_in: "iniciar-sessao", sign_out: "sair", password: "senha"
  }

  root "products#index"
  get "/produtos", to: "products#index", as: :produtos
  get "/sabores", to: "products#index", as: :sabores
  get "/produtos/:slug", to: "products#show", as: :produto
  get "/categorias/:slug", to: "products#index", as: :categoria
  get "/quem-somos", to: "pages#about", as: :quem_somos
  get "/contato", to: "pages#contact", as: :contato
  get "/carrinho", to: "cart#show", as: :carrinho
  post "/carrinho/itens", to: "cart#create", as: :cart_items
  patch "/carrinho/itens/:key", to: "cart#update", as: :cart_item
  delete "/carrinho/itens/:key", to: "cart#destroy"
  delete "/carrinho", to: "cart#clear"
  get "/finalizar-pedido", to: "checkout#new", as: :finalizar_pedido
  post "/finalizar-pedido", to: "checkout#create"
  get "/health", to: "health#show", defaults: { format: :json }
  get "/up", to: "health#show", defaults: { format: :json }

  namespace :admin, path: "administracao" do
    root "dashboard#index"
    post "pedidos/alternar-recebimento", to: "dashboard#toggle_orders", as: :toggle_orders
    resources :categories
    resources :products
    resources :orders, only: %i[index show]
    resources :customers, except: :new
    resources :financial_entries, path: "financeiro"
  end
end
