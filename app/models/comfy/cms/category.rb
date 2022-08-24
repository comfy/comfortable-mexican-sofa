class Comfy::Cms::Category < ActiveRecord::Base
  self.table_name = 'comfy_cms_categories'

  # -- Relationships --------------------------------------------------------
  belongs_to :site
  has_many :categorizations,
    :dependent => :destroy

  # -- Callbacks ------------------------------------------------------------
  before_validation :create_slug

  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => { :scope => [:categorized_type, :site_id] }
  validates :categorized_type,
    :presence   => true


  # -- Scopes ---------------------------------------------------------------
  default_scope{ order(:label) }
  
  scope :of_type, lambda { |type|
    where(:categorized_type => type)
  }

  protected

  # Create slug from Label
  def create_slug
    return if label.nil? or label.empty?
    self.slug = label.downcase.gsub(/[^a-z0-9\-]/, '-')
  end
end
