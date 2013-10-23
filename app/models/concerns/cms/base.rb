module Cms::Base
  extend ActiveSupport::Concern
  
  included do 
    # Establishing database connection if custom one is defined
    if ComfortableMexicanSofa.config.database_config && !Rails.env.test?
      establish_connection "#{ComfortableMexicanSofa.config.database_config}_#{Rails.env}"
    end
  end
  
  module ClassMethods
    def table_name_prefix
      'cms_'
    end
  end
  
end