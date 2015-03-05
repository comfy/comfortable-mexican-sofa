module ComfortableMexicanSofa::IsCategorized

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def cms_is_categorized
      has_many :categorizations,
        :as         => :categorized,
        :class_name => 'Comfy::Cms::Categorization',
        :dependent  => :destroy,
        :validate   => false
      has_many :categories,
        :through    => :categorizations,
        :class_name => 'Comfy::Cms::Category'

      attr_accessor :is_mirrored_with_categorizations

      scope :for_category, lambda { |*categories|
        if (categories = [categories].flatten.compact).present?
          self.distinct.
            joins(:categorizations => :category).
            where('comfy_cms_categories.label' => categories)
        end
      }
      include ComfortableMexicanSofa::IsCategorized::InstanceMethods
    end
  end

  module InstanceMethods

    # Method to reset the categories of a categorized item based in a form params.
    def category_ids=(new_ids)
      self.is_mirrored_with_categorizations = true
      new_ids = new_ids.select { |k, v| [1, '1', true, 'true'].include?(v) }.keys if new_ids.is_a?(Hash)
      assign_new_categories!(new_ids)
    end

    # New categories for this item. Remove old ones, create new ones and keep the still valid ones.
    def assign_new_categories!(new_ids)
      valid_new_category_ids = new_ids.find_all(&:present?).map(&:to_i)
      current_category_ids   = categorizations.map(&:category_id)
      categorize!(valid_new_category_ids - current_category_ids)
      uncategorize!(current_category_ids - valid_new_category_ids)
    end

    private

    # Associates a category to this item.
    def categorize!(category_ids)
      action = is_mirrored_with_categorizations ? :build : :create
      category_ids.each { |id| categorizations.send(action, category_id: id) }
    end

    # Disassociates a category to this item.
    def uncategorize!(category_ids)
      categorizations.where(category_id: category_ids).each(&:destroy)
    end
  end
end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::IsCategorized
