# frozen_string_literal: true

module Comfy::Cms::WithFragments
  extend ActiveSupport::Concern

  included do
    attr_accessor :fragments_attributes_changed

    belongs_to :layout,
               class_name: 'Comfy::Cms::Layout'

    has_many :fragments,
             class_name: 'Comfy::Cms::Fragment',
             as: :record,
             autosave: true,
             dependent: :destroy

    before_save :clear_content_cache

    validates :layout,
              presence: true
  end

  # Array of fragment hashes in the following format:
  #   [
  #     {identifier: "frag_a", format: "text", content: "fragment a content"},
  #     {identifier: "frag_b", format: "file", files: [{file_a}, {file_b}]}
  #   ]
  # It also handles when frag hashes come in as a hash:
  #   {
  #     "0" => {identifer: "foo", content: "bar"},
  #     "1" => {identifier: "bar", content: "foo"}
  #   }
  def fragments_attributes=(frag_hashes = [])
    frag_hashes = frag_hashes.values if frag_hashes.is_a?(Hash)

    frag_hashes.each do |frag_attrs|
      unless frag_attrs.is_a?(HashWithIndifferentAccess)
        frag_attrs.symbolize_keys!
      end

      identifier = frag_attrs.delete(:identifier)

      fragment =
        fragments.detect { |f| f.identifier == identifier } ||
        fragments.build(identifier: identifier)

      fragment.attributes = frag_attrs

      # tracking dirty
      self.fragments_attributes_changed ||= fragment.changed?
    end
  end

  # Snapshop of page fragments data used primarily for saving revisions
  def fragments_attributes(was = false)
    fragments.collect do |frag|
      attrs = {}
      %i[identifier tag content datetime boolean].each do |column|
        attrs[column] = frag.send(was ? "#{column}_was" : column)
      end
      # TODO: save files against revision (not on db though)
      # attrs[:files] = frag.attachments.collect do |a|
      #   {io: a.download, filename: a.filename.to_s, content_type: a.content_type}
      # end
      attrs
    end
  end

  # Method to collect prevous state of blocks for revisions
  def fragments_attributes_was
    fragments_attributes(:previous_values)
  end

  # Grabbing nodes that we need to render form elements in the admin area
  # Rejecting duplicates as we'd need to render only one form field. Don't declare
  # duplicate tags on the layout. That's wierd (but still works).
  def fragment_nodes
    nodes
      .select { |n| n.is_a?(ComfortableMediaSurfer::Content::Tags::Fragment) }
      .uniq(&:identifier)
  end

  # Rendered content of the page. We grab whatever layout is associated with the
  # page and feed its content tokens to the renderer while passing this page as
  # context.
  def render(n = nodes)
    renderer.render(n)
  end

  # If content_cache column is populated we don't need to call render for this
  # page.
  def content_cache
    if (cache = read_attribute(:content_cache)).nil?
      cache = render
      update_column(:content_cache, cache) unless new_record?
    end
    cache
  end

  # Nuking content cache so it can be regenerated.
  def clear_content_cache!
    update_column(:content_cache, nil)
  end

  # Blanking cache on page saves so it can be regenerated on access
  def clear_content_cache
    write_attribute(:content_cache, nil)
  end

protected

  def renderer
    ComfortableMediaSurfer::Content::Renderer.new(self)
  end

  def nodes
    return [] unless layout.present?

    tokens = layout.content_tokens
    renderer.nodes(tokens)
  end
end
