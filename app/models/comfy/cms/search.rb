class Comfy::Cms::Search

  def initialize(scope, search_term)
    @scope = scope
    @search_term = search_term
  end

  def results
    @scope.with_label_like(@search_term)
  end

end
