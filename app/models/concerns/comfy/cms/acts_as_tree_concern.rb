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

    def tree(records:)
      records = records.reject(&:new_record?)

      grouped_records =
        records.group_by(&:parent_id).transform_values do |grouping|
          grouping.sort_by(&:position)
        end

      walk_tree = lambda do |parent_id = nil|
        grouped_records.fetch(parent_id, []).map do |child|
          { id: child.id, label: child.label, children: walk_tree.call(child.id) }
        end
      end

      walk_tree.call
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
