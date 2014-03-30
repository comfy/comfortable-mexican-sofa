module ComfortableMexicanSofa::IsMirrored
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    def cms_is_mirrored
      include ComfortableMexicanSofa::IsMirrored::InstanceMethods
      
      attr_accessor :is_mirrored
      
      after_save    :sync_mirror
      after_destroy :destroy_mirror
    end
  end
  
  module InstanceMethods
    
    # Mirrors of the object found on other sites
    def mirrors
      return [] unless self.site.is_mirrored?
      (Comfy::Cms::Site.mirrored - [self.site]).collect do |site|
        case self
          when Comfy::Cms::Layout  then site.layouts.find_by_identifier(self.identifier)
          when Comfy::Cms::Page    then site.pages.find_by_full_path(self.full_path)
          when Comfy::Cms::Snippet then site.snippets.find_by_identifier(self.identifier)
        end
      end.compact
    end
    
    # Creating or updating a mirror object. Relationships are mirrored
    # but content is unique. When updating need to grab mirrors based on
    # self.slug_was, new objects will use self.slug.
    def sync_mirror
      return if self.is_mirrored || !self.site.is_mirrored?
      
      (Comfy::Cms::Site.mirrored - [self.site]).each do |site|
        mirror = case self
        when Comfy::Cms::Layout
          m = site.layouts.find_by_identifier(self.identifier_was || self.identifier) || site.layouts.new
          m.attributes = {
            :identifier => self.identifier,
            :parent_id  => site.layouts.find_by_identifier(self.parent.try(:identifier)).try(:id)
          }
          m
        when Comfy::Cms::Page
          m = site.pages.find_by_full_path(self.full_path_was || self.full_path) || site.pages.new
          m.attributes = {
            :slug       => self.slug,
            :label      => m.label.blank?? self.label : m.label,
            :parent_id  => site.pages.find_by_full_path(self.parent.try(:full_path)).try(:id),
            :layout     => site.layouts.find_by_identifier(self.layout.try(:identifier))
          }
          m
        when Comfy::Cms::Snippet
          m = site.snippets.find_by_identifier(self.identifier_was || self.identifier) || site.snippets.new
          m.attributes = {
            :identifier => self.identifier
          }
          m
        end
        
        mirror.is_mirrored = true
        begin
          mirror.save!
        rescue ActiveRecord::RecordInvalid => e
          logger.error(e.message)
          logger.error(e.backtrace.each{|line| error line })
        end
      end
    end
    
    # Mirrors should be destroyed
    def destroy_mirror
      return if self.is_mirrored || !self.site.is_mirrored?
      mirrors.each do |mirror|
        mirror.is_mirrored = true
        mirror.destroy
      end
    end
  end
  
end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::IsMirrored
