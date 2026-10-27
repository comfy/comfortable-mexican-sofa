# frozen_string_literal: true

class Comfy::Cms::Layout < Comfy::Cms::ApplicationRecord
  self.table_name = "comfy_cms_layouts"

  cms_acts_as_tree

  cms_has_revisions_for :content, :css, :js

  # -- Relationships --------------------------------------------------------
  belongs_to :site

  has_many :pages, dependent: :nullify

  # -- Callbacks ---------------------------------------------------------------
  before_validation :assign_label
  before_create :assign_position
  before_destroy :clear_page_content_cache, prepend: true
  after_save     :clear_page_content_cache

  # -- Validations -------------------------------------------------------------

  validates :label, presence: true
  validates :identifier,
            presence:   true,
            uniqueness: { scope: :site_id },
            format:     { with: /\A\w[a-z0-9_-]*\z/i }

  # -- Class Methods -----------------------------------------------------------
  # Tree-like structure for layouts
  def self.options_for_select(site, current_layout = nil)
    options_for_layout = lambda do |layout, depth = 0|
      return if layout == current_layout

      current_option = [["#{'. . ' * depth}#{layout.label}", layout.id]]

      children_options =
        layout.children.order(:position).flat_map do |child_layout|
          options_for_layout.call(child_layout, depth + 1)
        end

      current_option + children_options
    end

    site.layouts.roots.order(:position).flat_map do |root_layout|
      options_for_layout.call(root_layout)
    end
  end

  # List of available application layouts
  def self.app_layouts_for_select(view_paths)
    local_paths = view_paths.map(&:to_s).select { |path| path.start_with?(Rails.root.to_s) }

    local_paths.flat_map do |layouts_dir|
      layout_files = Dir.glob(File.join(layouts_dir, "layouts", "**", "*.html.*"))

      layout_files.filter_map do |file_path|
        relative_path = file_path.sub("#{layouts_dir}/layouts/", "")
        filename = File.basename(relative_path)

        next if filename.start_with?("_")

        relative_path.split(".").first
      end
    end.uniq.sort
  end

  # -- Instance Methods --------------------------------------------------------
  # Tokenized layout content that also pulls in parent layout (if there's one)
  # and merges on the {{cms:tag_type content}} tag (if parent layout has that).
  # Returns a list of tokens that can be fed into the renderer.
  def content_tokens
    renderer  = ComfortableMexicanSofa::Content::Renderer.new(nil)
    tokens    = renderer.tokenize(content)

    if parent
      fragment_tags =
        ComfortableMexicanSofa::Content::FragmentTag.subclasses.map do |c|
          ComfortableMexicanSofa::Content::Renderer.tags.key(c)
        end

      parent_tokens = parent.content_tokens

      replacement_position = parent_tokens.index do |n|
        n.is_a?(Hash) &&
          fragment_tags.member?(n[:tag_class]) &&
          n[:tag_params].split(/\s/).first == "content"
      end

      if replacement_position
        parent_tokens[replacement_position] = tokens
        tokens = parent_tokens.flatten
      end
    end

    tokens
  end

  def cache_buster
    updated_at.to_i
  end

  # Forcing page content reload
  def clear_page_content_cache
    Comfy::Cms::Page.where(id: pages.pluck(:id)).update_all(content_cache: nil)
    children.each(&:clear_page_content_cache)
  end

protected

  def assign_label
    return if identifier.blank? || label.present?

    self.label = identifier.titleize
  end

  def assign_position
    return if position.to_i.positive?

    max = site.layouts.where(parent_id: parent_id).maximum(:position)
    self.position = max ? max + 1 : 0
  end
end
