module ActsAsCategorized
  module StubMethods
    
    def acts_as_categorized
      
      __categorized = self.to_s.underscore.to_sym
      __categorizations = "#{__categorized}_categorizations".to_sym
      
      # -- Attributes -------------------------------------------------------
      attr_accessor :attr_category_ids # hash that comes from the form
      
      # -- Relationships ----------------------------------------------------
      has_many __categorizations,
        :dependent  => :destroy
      has_many :cms_categories, 
        :through    => __categorizations
      
      # -- Callbacks --------------------------------------------------------
      after_save :save_categorizations
      
      # -- Named Scopes -----------------------------------------------------
      
      scope :in_category, lambda { |category| {
        :joins => __categorizations,
        :conditions => { __categorizations => {:cms_category_id => (category.is_a?(CmsCategory) ? category.id : category) } }
      }}
      
      # -- Instance Methods -------------------------------------------------
      define_method :save_categorizations do
        return if attr_category_ids.blank?
        
        category_ids_to_remove = attr_category_ids.select{ |k, v| v.to_i == 0}.collect{|k, v| k }
        category_ids_to_create = attr_category_ids.select{ |k, v| v.to_i == 1}.collect{|k, v| k }
        
        # removing unchecked categories
        send(__categorizations).all(:conditions => { :cms_category_id => category_ids_to_remove}).collect(&:destroy)
        
        # creating categorizations
        category_ids_to_create.each do |category_id|
          send(__categorizations).create(:cms_category_id => category_id)
        end
      end
    end
    
    def acts_as_categorization
      
      __categorized = self.to_s.underscore.gsub('_categorization', '').to_sym
      __categorized_id = "#{__categorized}_id".to_sym
      __categorizations = "#{__categorized}_categorizations".to_sym
      
      # -- Relationships --------------------------------------------------------
      belongs_to __categorized.to_sym
      belongs_to :cms_category
      
      # -- Validations ----------------------------------------------------------
      validates_presence_of __categorized_id,
                            :cms_category_id
                            
      validates_uniqueness_of __categorized_id, :scope => :cms_category_id
      
      # -- AR Callbacks ---------------------------------------------------------
      after_save :create_parent_categorization
      after_destroy :destroy_children_categorizations
      
      # -- Instance Methods -----------------------------------------------------
      define_method :create_parent_categorization do
        return unless cms_category.parent
        
        params = {
          :cms_category_id  => cms_category.parent_id,
          __categorized_id  => send(__categorized).id
        }
        self.class.create!(params) unless self.class.exists?(params)
      end
      
      define_method :destroy_children_categorizations do
        return if cms_category.children.blank?
        
        cms_category.children.each do |c|
          send(__categorized).send(__categorizations).first(:conditions => {"cms_category_id" => c.id }).try(:destroy)
        end
      end
    end
  end
end

ActiveRecord::Base.extend(ActsAsCategorized::StubMethods)

