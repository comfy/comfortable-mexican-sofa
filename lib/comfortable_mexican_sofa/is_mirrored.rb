module ComfortableMexicanSofa::IsMirrored
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    
    def is_mirrored
      include ComfortableMexicanSofa::IsMirrored::InstanceMethods
      
      attr_accessor :is_mirrored
      
      after_save    :sync_mirror
      after_destroy :destroy_mirror
    end
  end
  
  module InstanceMethods
    
    def sync_mirror
      return if self.is_mirrored
      
      Cms::Site.all.each do |site|
        mirror = case self
        when Cms::Layout
          site.layouts.find_by_slug(self.slug) || site.layouts.new(:slug => self.slug)
        when Cms::Page
          
        when Cms::Snippet
          site.snippets.find_by_slug(self.slug) || site.snippets.new(:slug => self.slug)
        end
        
        mirror.is_mirrored = true
        mirror.save!
      end
    end
    
    def destroy_mirror
      return if self.is_mirrored
      
      # TODO
    end
  end
  
end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::IsMirrored