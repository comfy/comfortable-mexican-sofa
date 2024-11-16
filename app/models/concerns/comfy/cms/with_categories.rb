# frozen_string_literal: true

module Comfy::Cms::WithCategories
  extend ActiveSupport::Concern

  included do
    has_many :categorizations,
             as: :categorized,
             class_name: 'Comfy::Cms::Categorization',
             dependent: :destroy
    has_many :categories,
             through: :categorizations,
             class_name: 'Comfy::Cms::Category'

    attr_writer :category_ids

    after_save :sync_categories

    scope :for_category, ->(*categories) {
      if (categories = [categories].flatten.compact).present?
        distinct
          .joins(categorizations: :category)
          .where('comfy_cms_categories.label' => categories)
      end
    }
  end

  def category_ids
    @category_ids ||= categories.pluck(:id)
  end

  def sync_categories
    return unless category_ids.is_a?(Array)

    scope = Comfy::Cms::Category.of_type(self.class.to_s)
    existing_ids = scope.pluck(:id)

    ids_to_add = category_ids.map(&:to_i)

    # adding categorizations
    ids_to_add.each do |id|
      if (category = scope.find_by_id(id))
        category.categorizations.create(categorized: self)
      end
    end

    # removing categorizations
    ids_to_remove = existing_ids - ids_to_add
    categorizations.where(category_id: ids_to_remove).destroy_all
  end
end
