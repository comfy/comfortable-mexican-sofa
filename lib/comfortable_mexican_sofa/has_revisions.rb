module ComfortableMexicanSofa::HasRevisions
  
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
  end
  
  module ClassMethods
    
    def has_revisions_for(*fields)
      
      attr_accessor :revision_data
      
      has_many :revisions,
        :as         => :record,
        :dependent  => :destroy
        
      before_save :prepare_revision
      after_save  :create_revision
      
      define_method(:revision_fields) do
        fields.collect(&:to_s)
      end
    end
  end
  
  module InstanceMethods
    
    def prepare_revision
      if !(self.changed & revision_fields).empty?
        self.revision_data = revision_fields.inject({}) do |c, field|
          c[field] = self.send("#{field}_was")
          c
        end
      end
    end
    
    def create_revision
      return unless self.revision_data
      self.revisions.create!(:data => self.revision_data)
    end
    
  end
  
end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::HasRevisions