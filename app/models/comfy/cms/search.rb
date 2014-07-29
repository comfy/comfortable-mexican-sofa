class Comfy::Cms::Search

  def initialize(object, search_term)
    @object = object
    @search_term = search_term
  end

  def results
    @object.with_label_like(@search_term)
  end

end
