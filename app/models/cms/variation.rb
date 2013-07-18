class Cms::Variation < ActiveRecord::Base

  self.table_name = 'cms_variations'

  # -- Relationships --------------------------------------------------------
  belongs_to :content,
    :polymorphic => true,
    :inverse_of  => :variations


  # -- Validations ----------------------------------------------------------
  validates :content, :identifier,
    :presence => true
  validates :identifier,
    :uniqueness => {:scope => :content}
  validate :validate_uniqueness_per_page

  def self.list(variations = nil, namespace = nil)
    variations ||= ComfortableMexicanSofa.config.variations
    namespace  ||= nil
    output       = []

    case variations
      when Array
        variations.each do |identifier|
          if namespace
            output << "#{namespace}.#{identifier}"
          else
            output << "#{identifier}"
          end
        end
      when Hash
        variations.each do |namespace, identifiers|
          output << self.list(identifiers, namespace)
        end
    end
    output.flatten
  end

protected

  def validate_uniqueness_per_page
    exists = self.content.page.page_contents.for_variation(self.identifier)
      .where('cms_page_contents.id NOT IN (?)', (self.content.id || 0)).exists?
    self.errors.add(:identifier, 'That identifier already exists') if exists
  end

end