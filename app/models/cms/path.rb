module Cms::Path
  extend ActiveSupport::Concern

  included do
    before_validation :assign_full_path,
                      :escape_slug
    after_save   :assign_childrens_full_path
    after_commit :reassign_full_path, :on => :destroy
  end

  # Idea here is to reassign all the paths for all the page contents that are the children of the page of the deleted page content.
  
  def reassign_full_path
    # The page of the deleted page content
    page = self.page

    # Recursively load the children pages
    pages = [page]
    pages.each do |page|
      children_page = Cms::Page.where(:parent_id => page.id).to_a
      pages << children_page if children_page
      pages.flatten!
    end
    
    # Load the page contents for all the pages above
    page_contents = []
    pages.each do |page|
      children_page_content = page.page_contents.to_a
      page_contents << children_page_content if children_page_content
      page_contents.flatten!
    end

    # Recalculate all the page pages for the page contents
    page_contents.each do |page_content|
      unless page_content.frozen?
        page_content.assign_full_path
        page_content.save!
      end
    end
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
    self.full_path = slug_path.join('/').squeeze('/')
    # self.full_path = CGI::escape(full_path).gsub('%2F', '/')
  end

  # Full url for a page
  def url
    "http://" + "#{self.site.hostname}/#{self.site.path}/#{self.full_path}".squeeze("/")
  end

  def full_path
    self.read_attribute(:full_path) || self.assign_full_path
  end

  # Escape slug unless it's nonexistent (root) or already escaped, which is
  # possible if we validate more than once
  def escape_slug
    self.slug = CGI::escape(self.slug) unless self.slug.nil? || @escaped
    @escaped = true
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