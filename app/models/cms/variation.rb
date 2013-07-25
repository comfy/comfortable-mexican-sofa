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
    pc         = self.content
    page       = pc.page
    variations = page.page_contents.collect { |pc| pc.variations.pluck(:identifier) }.flatten
    # If this variation already exists, then add an error
    errors.add(:identifier, "That identifier already exists") if variations.include?(self.identifier) && self.new_record?
  end

end