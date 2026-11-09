# frozen_string_literal: true

module Comfy::Cms::ActsAsTreeConcern
  extend ActiveSupport::Concern

  included do
    belongs_to :parent,
      optional:   true,
      class_name: name

    has_many :children,
      foreign_key: :parent_id,
      dependent:   :destroy,
      inverse_of:  :parent,
      class_name:  name

    scope :roots, -> { where(parent_id: nil) }

    validate :validate_parent_id,
             :validate_site_scoping
  end

  class_methods do
    def root
      roots.first
    end
  end

  def root?
    parent_id.nil?
  end

  def descendants
    children.flat_map { |child| [child] + child.descendants }
  end

private

  def validate_parent_id
    return if parent_id.blank?

    if id == parent_id
      errors.add(:parent_id, "cannot be its own parent")
    elsif descendants.map(&:id).include?(parent_id)
      errors.add(:parent_id, "cannot be a descendant's parent")
    end
  end

  def validate_site_scoping
    return if parent_id.blank?

    if site_id != parent&.site_id
      errors.add(:parent_id, "wrong site scope")
    end
  end
end
