# frozen_string_literal: true

class Comfy::Cms::Layout < ActiveRecord::Base
  self.table_name = 'comfy_cms_layouts'

  require_relative '../../../../lib/comfortable_media_surfer/extensions/acts_as_tree'

  cms_acts_as_tree
  cms_has_revisions_for :content, :css, :js

  # -- Relationships --------------------------------------------------------
  belongs_to :site
  has_many :pages, dependent: :nullify

  # -- Callbacks ---------------------------------------------------------------
  before_validation :assign_label
  before_create :assign_position
  after_save    :clear_page_content_cache
  after_destroy :clear_page_content_cache

  # -- Validations -------------------------------------------------------------
  validates :site_id,
            presence:   true
  validates :label,
            presence:   true
  validates :identifier,
            presence: true,
            uniqueness: { scope: :site_id },
            format: { with: %r{\A\w[a-z0-9_-]*\z}i }

  # -- Class Methods -----------------------------------------------------------
  # Tree-like structure for layouts
  def self.options_for_select(site, current_layout = nil)
    options = []

    options_for_layout = ->(layout, depth = 0) do
      return if layout == current_layout

      options << ["#{'. . ' * depth}#{layout.label}", layout.id]

      layout.children.order(:position).each do |child_layout|
        options_for_layout.call(child_layout, depth + 1)
      end
    end

    site.layouts.roots.order(:position).each do |layout|
      options_for_layout.call(layout)
    end

    options
  end

  # List of available application layouts
  def self.app_layouts_for_select(view_paths)
    view_paths.map(&:to_s).select { |path| path.start_with?(Rails.root.to_s) }.flat_map do |full_path|
      Dir.glob("#{full_path}/layouts/**/*.html.*").collect do |filename|
        filename.gsub!("#{full_path}/layouts/", '')
        filename.split('/').last[0...1] == '_' ? nil : filename.split('.').first
      end.compact.sort
    end.compact.uniq.sort
  end

  # -- Instance Methods --------------------------------------------------------
  # Tokenized layout content that also pulls in parent layout (if there's one)
  # and merges on the {{cms:tag_type content}} tag (if parent layout has that).
  # Returns a list of tokens that can be fed into the renderer.
  def content_tokens
    renderer  = ComfortableMediaSurfer::Content::Renderer.new(nil)
    tokens    = renderer.tokenize(content)

    if parent
      fragment_tags = ComfortableMediaSurfer::Content::Tags::Fragment.subclasses.map do |c|
        ComfortableMediaSurfer::Content::Renderer.tags.key(c)
      end

      parent_tokens = parent.content_tokens
      replacement_position = parent_tokens.index do |n|
        n.is_a?(Hash) &&
          fragment_tags.member?(n[:tag_class]) &&
          n[:tag_params].split(%r{\s}).first == 'content'
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
    self.label = label.blank? ? identifier.try(:titleize) : label
  end

  def assign_position
    return if position.to_i.positive?

    max = site.layouts.where(parent_id: parent_id).maximum(:position)
    self.position = max ? max + 1 : 0
  end
end
