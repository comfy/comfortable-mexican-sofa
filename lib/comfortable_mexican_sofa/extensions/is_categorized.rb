module ComfortableMexicanSofa::IsCategorized

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def cms_is_categorized
      include ComfortableMexicanSofa::IsCategorized::InstanceMethods

      has_many :categorizations,
        :as         => :categorized,
        :class_name => 'Comfy::Cms::Categorization',
        :dependent  => :destroy
      has_many :categories,
        :through    => :categorizations,
        :class_name => 'Comfy::Cms::Category'

      attr_accessor :category_ids

      after_save :sync_categories

      scope :for_category, lambda { |*categories|
        if (categories = [categories].flatten.compact).present?
          self.distinct.
            joins(:categorizations => :category).
            where('comfy_cms_categories.label' => categories)
        end
      }
    end
  end

  module InstanceMethods
    def sync_categories
      self.categorizations.destroy_all
      (self.category_ids || {}).each do |category_id|
        if category = Comfy::Cms::Category.find_by_id(category_id)
          category.categorizations.create(:categorized => self)
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::IsCategorized
