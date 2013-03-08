defined?(ComfortableMexicanSofa::Application) && ComfortableMexicanSofa::Application.routes.draw do
  ComfortableMexicanSofa::Routing.admin
  ComfortableMexicanSofa::Routing.content :sitemap => true
end
