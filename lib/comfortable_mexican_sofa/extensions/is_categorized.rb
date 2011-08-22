module ComfortableMexicanSofa::IsCategorized
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    def cms_is_categorized
      has_many :categories,
        :through  => :categorizations,
        :as       => :categorized
    end
  end
  
end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::IsCategorized