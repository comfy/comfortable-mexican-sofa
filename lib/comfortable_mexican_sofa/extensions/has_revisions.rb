module ComfortableMexicanSofa::HasRevisions
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    
    def cms_has_revisions_for(*fields)
      
      include ComfortableMexicanSofa::HasRevisions::InstanceMethods
      
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
    
    # Preparing revision data. A bit of a special thing to grab page blocks
    def prepare_revision
      return if self.new_record?
      if (self.respond_to?(:blocks_attributes_changed) && self.blocks_attributes_changed) || 
        !(self.changed & revision_fields).empty?
        self.revision_data = revision_fields.inject({}) do |c, field|
          c[field] = self.send("#{field}_was")
          c
        end
      end
    end
    
    # Revision is created only if relevant data changed
    def create_revision
      return unless self.revision_data
      
      # creating revision
      if ComfortableMexicanSofa.config.revisions_limit.to_i != 0
        self.revisions.create!(:data => self.revision_data)
      end
      
      # blowing away old revisions
      ids = [0] + self.revisions.limit(ComfortableMexicanSofa.config.revisions_limit.to_i).collect(&:id)
      self.revisions.where('id NOT IN (?)', ids).destroy_all
    end
    
    # Assigning whatever is found in revision data and attemptint to save the object
    def restore_from_revision(revision)
      return unless revision.record == self
      self.update_attributes!(revision.data)
    end
  end
end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::HasRevisions