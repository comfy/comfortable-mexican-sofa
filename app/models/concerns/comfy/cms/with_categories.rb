module Comfy::Cms::WithCategories
  extend ActiveSupport::Concern

  included do
    has_many :categorizations,
      as:         :categorized,
      class_name: "Comfy::Cms::Categorization",
      dependent:  :destroy
    has_many :categories,
      through:    :categorizations,
      class_name: "Comfy::Cms::Category"

    attr_accessor :category_ids

    after_save :sync_categories

    scope :for_category, ->(*categories) {
      if (categories = [categories].flatten.compact).present?
        distinct.
          joins(categorizations: :category).
          where("comfy_cms_categories.label" => categories)
      end
    }
  end

  def sync_categories
    (category_ids || {}).each do |category_id, flag|
      case flag.to_i
      when 1
        if (category = Comfy::Cms::Category.find_by_id(category_id))
          category.categorizations.create(categorized: self)
        end
      when 0
        categorizations.where(category_id: category_id).destroy_all
      end
    end
  end
end
