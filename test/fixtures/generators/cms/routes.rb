Test::Application.routes.draw do

  ComfortableMexicanSofa::Routing.admin :path => '/admin'

  # Make sure this routeset is defined last
  ComfortableMexicanSofa::Routing.content :path => '/', :sitemap => false

end