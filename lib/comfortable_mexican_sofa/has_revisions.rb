module ComfortableMexicanSofa::HasRevisions
  
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
  end
  
  module ClassMethods
    
    def has_revisions_for(*fields)
      
      has_many :revisions,
        :as         => :record,
        :dependent  => :destroy
        
      before_save :create_revision
      
      define_method(:revision_fields) do
        fields
      end
    end
  end
  
  module InstanceMethods
    
    def create_revision
      # ...
    end
    
  end
  
end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::HasRevisions