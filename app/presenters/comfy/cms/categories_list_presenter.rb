require 'delegate'

class Comfy::Cms::CategoriesListPresenter < SimpleDelegator

  def all
    model.all.map { |category| [category.label, category.id] }
  end

  def selected(page)
    model.all.map { |category| category.id if page.categories.member?(category) }.compact
  end

  def model
    __getobj__
  end

end
