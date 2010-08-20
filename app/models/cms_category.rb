class CmsCategory < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  acts_as_tree :counter_cache => :children_count
  
  has_many :cms_page_categorizations,       :dependent => :destroy
  
  has_many :cms_pages,        :through => :cms_page_categorizations
  
  # -- Validations ----------------------------------------------------------
  validates_presence_of :slug, :label
  validates_uniqueness_of :slug, :scope => :parent_id
  
  # -- Named Scopes ---------------------------------------------------------
  default_scope :order => 'label'
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :set_slug_if_blank
  
  # -- Class Methods --------------------------------------------------------
  def set_slug_if_blank
    self.slug = self.label.slugify if self.slug.blank?
  end

  def self.categories_for_select(collection = CmsCategory.roots, level = 0)
    out = []
    collection.each do |category|
      out += [["#{". . " * level} #{category.label}", category.id]]
      out += self.categories_for_select(category.children, level+1) if category.children.count > 0
    end
    out
  end

  def self.categorized_model_names
    model_names = []
    CmsCategory.reflect_on_all_associations(:has_many).each do |model|
      model_names << model.klass.to_s if model.through_reflection.present?
    end
    model_names
  end

  def self.categorized_model_types
    models_types = []
    CmsCategory.categorized_model_names.each do |model_name|
      models_types << model_name.constantize
    end
    models_types
  end

  # -- Instance Methods -----------------------------------------------------
  def number_of_records
    # returns the number of records (of all types) under a certain category
    count = 0
    CmsCategory.categorized_model_names.each do |model_name|
      count += self.send(model_name.underscore.pluralize.to_sym).length
    end
    count
  end

  def records
    things = {}
    CmsCategory.categorized_model_names.each do |model_name|
      model_sym = model_name.underscore.pluralize.to_sym
      things[model_sym] = self.send(model_sym)
    end
    things
  end
end

