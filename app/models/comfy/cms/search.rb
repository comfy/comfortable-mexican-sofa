class Comfy::Cms::Search
  attr_reader :scope, :search_term

  def initialize(scope, search_term)
    @scope = scope
    @search_term = search_term.strip
  end

  def results
    matching_pages.sort_by do |page|
      [ComfortableMexicanSofa::SearchScore.new(search_term, page.label, page.blocks).score, page.updated_at]
    end.reverse
  end

  private

  def matching_pages
    (matching_page_labels + matching_page_content + matching_page_slug).uniq
  end

  def matching_page_labels
    scope.with_label_like(search_term)
  end

  def matching_page_content
    scope.includes(:blocks).with_content_like(search_term)
  end

  def matching_page_slug
    scope.with_slug_like(search_term)
  end
end
