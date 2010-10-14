Rails.application.routes.draw do
  
  namespace :cms_admin, :path => 'cms-admin', :except => :show do
    resources :sites
    resources :layouts
    resources :pages do
      member do 
        match :form_blocks
      end
    end
    resources :snippets
    resources :uploads
  end
  
  scope :controller => :cms_content do
    get '/cms-css/:id'  => :render_css,   :format => 'css'
    get '/cms-js/:id'   => :render_js,    :format => 'js'
    get '/'             => :render_html,  :path => '(*cms_path)'
  end
  
end
