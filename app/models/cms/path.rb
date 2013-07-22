module Cms::Path
  extend ActiveSupport::Concern

  included do
    before_validation :assign_full_path,
                      :escape_slug
    after_save :assign_childrens_full_path
  end


  def assign_full_path
    # Set the full_path to '/' if this is the first page or we are updating
    # the root page
    return self.full_path = '/' if self.page.site.pages.count == 0 || self.site.pages.root == self.page
    # Loop through the ancestors of this page_content and build the full path
    ancestors            = self.page.ancestors
    variation_identifier = self.variation_identifiers.first
    slug_path = []
    ancestors.reverse.each do |ancestor|
      # If this ancestor has a matching variation_identifier then we should
      # use that slug to build the full_path. It's entirely possible that
      # this page_content has multiple variation identifiers - which is why
      # we are simply going to match the first (default). When a page_content
      # is changed in the future, then we will regenerate all full_paths in
      # the tree.
      matching_identifier = ideal_identifier_for(ancestor)
      matching_content    = ancestor.page_contents.for_variation(matching_identifier)
      # If this is a root page, then we should add '/' to the slug path,
      # otherwise, we should add the actual slug
      if ancestor.root?
        slug_path << '/'
      else
        slug_path << ancestor.page_contents.for_variation(matching_identifier).first.slug
      end
    end

    # Add this page_content's slug to the slug_path
    slug_path << self.slug
    # Escape all characters except '/'
    full_path = slug_path.join('/').squeeze('/')
    self.full_path = CGI::escape(full_path).gsub('%2F', '/')
  end

  # Full url for a page
  def url
    "http://" + "#{self.site.hostname}/#{self.site.path}/#{self.full_path}".squeeze("/")
  end

  def full_path
    self.read_attribute(:full_path) || self.assign_full_path
  end

  # Escape slug unless it's nonexistent (root)
  def escape_slug
    self.slug = CGI::escape(self.slug) unless self.slug.nil?
  end

  # Unescape the slug and full path back into their original forms unless they're nonexistent
  def unescape_slug_and_path
    self.slug       = CGI::unescape(self.slug)      unless self.slug.nil?
    self.full_path  = CGI::unescape(self.full_path) unless self.full_path.nil?
  end

  # Loop through all child pages and rebuild the URLs
  def assign_childrens_full_path
    self.page.children.each do |page|
      page.page_contents.each do |page_content|
        page_content.assign_full_path
        page_content.update_attributes(:full_path => self.full_path)
      end
    end
  end

private

  # Given a page, this method will find the ideal identifier match between
  # self.variation_identifiers and another page. The rules are simple – match
  # when possible, or choose the default (first) identifier.
  def ideal_identifier_for(page)
    parent_variations = page.page_contents.joins(:variations).pluck(:identifier)
    sorted_variations = sort_variations_by_defaults(parent_variations)
    # Loop through the sorted parent_variations and find the first matching
    # variation within self.variation_identifiers
    match = sorted_variations.find do |identifier|
      self.variation_identifiers.include?(identifier)
    end
    # If there is no match, then we should just choose the first possible
    # sorted_variation. This represents the "default" choice
    match || sorted_variations.first
  end

  # Returns a sorted list of variations. The sort order matches the order
  # defined in the comfortable_mexican_sofa.rb initilizer
  def sort_variations_by_defaults(possible_variations)
    possible_variations.sort_by! do |variation, index|
      if Cms::Variation.list.include?(variation)
        Cms::Variation.list.index(variation)
      else
        possible_variations.count + 1
      end
    end
  end

end