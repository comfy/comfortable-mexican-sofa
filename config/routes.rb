Rails.application.routes.draw do
  
  namespace :cms_admin, :path => 'cms-admin', :except => :show do
    get '/' => redirect('/cms-admin/pages')
    resources :pages do
      member do 
        match :form_blocks
      end
    end
    resources :sites
    resources :layouts
    resources :snippets
    resources :uploads
  end
  
  scope :controller => :cms_content do
    get '/cms-css/:id'  => :render_css,   :format => 'css'
    get '/cms-js/:id'   => :render_js,    :format => 'js'
    get '/'             => :render_html,  :path => '(*cms_path)'
  end
  
end
