module ComfortableMexicanSofa::IsRegulated

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def cms_is_regulated
      include ComfortableMexicanSofa::IsRegulated::InstanceMethods

      attr_accessor :is_mirrored_with_regulated_box

      after_save :sync_mirrors_with_regulated_box

    end
  end

  module InstanceMethods

    def regulated_box=(is_ticked)
      self.is_mirrored_with_regulated_box = true
      self.regulated = is_ticked
    end

    def regulated_box
      regulated
    end

    # Callbacks

    # Synchorize the regulated box of this item with the ones in its mirrors.
    def sync_mirrors_with_regulated_box
      if respond_to?(:mirrors) && is_mirrored_with_regulated_box
        mirrors.each { |mirror| mirror.update_attributes(regulated: self.regulated) }
      end
    end

  end
end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::IsRegulated
