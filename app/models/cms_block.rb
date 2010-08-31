class CmsBlock < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_page
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => { :scope => :cms_page_id }
  
  # -- Class Methods --------------------------------------------------------
  class << self
    # making sure that the correct class is initialized based on :type passed
    # primarily important for form processing
    def new_with_cast(*args, &block)
      if (h = args.first).is_a?(Hash) && (type = h[:type] || h['type']) && (klass = type.constantize) != self
        return klass.new(*args, &block)
      end
      new_without_cast(*args, &block)
    end
    alias_method_chain :new, :cast
  end
end
