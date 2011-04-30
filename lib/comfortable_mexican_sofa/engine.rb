require 'comfortable_mexican_sofa'
require 'rails'
require 'paperclip'
require 'active_link_to'
require 'mime/types'

module ComfortableMexicanSofa
  class Engine < ::Rails::Engine
    
    config.to_prepare do
      Dir.glob(File.expand_path('tags/*.rb', File.dirname(__FILE__))).each do |tag_path|
        require tag_path
      end
    end
    
  end
end

