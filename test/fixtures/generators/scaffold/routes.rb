Test::Application.routes.draw do

  namespace :admin do
    resources :foos
  end

end