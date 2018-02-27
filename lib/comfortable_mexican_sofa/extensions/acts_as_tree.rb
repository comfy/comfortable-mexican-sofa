# frozen_string_literal: true

module ComfortableMexicanSofa::ActsAsTree

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def cms_acts_as_tree(options = {})
      configuration = {
        foreign_key:    "parent_id",
        order:          nil,
        counter_cache:  nil,
        dependent:      :destroy,
        touch:          false
      }
      configuration.update(options) if options.is_a?(Hash)

      belongs_to :parent,
        optional:       true,
        class_name:     name,
        foreign_key:    configuration[:foreign_key],
        counter_cache:  configuration[:counter_cache],
        touch:          configuration[:touch]

      has_many :children,
        -> { order(configuration[:order]) },
        class_name:   name,
        foreign_key:  configuration[:foreign_key],
        dependent:    configuration[:dependent]

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        include ComfortableMexicanSofa::ActsAsTree::InstanceMethods

        scope :roots, -> {
          where("#{configuration[:foreign_key]} IS NULL").
          order(#{configuration[:order].nil? ? 'nil' : %("#{configuration[:order]}")})
        }

        def self.root
          roots.first
        end

        validates_each "#{configuration[:foreign_key]}" do |record, attr, value|
          if value
            if record.id == value
              record.errors.add attr, "cannot be it's own id"
            elsif record.descendants.map {|c| c.id}.include?(value)
              record.errors.add attr, "cannot be a descendant's id"
            end
          end
        end
      RUBY
    end

  end

  module InstanceMethods

    # Returns list of ancestors, starting from parent until root.
    #
    #   subchild1.ancestors # => [child1, root]
    def ancestors
      node  = self
      nodes = []
      nodes << node = node.parent while node.parent
      nodes
    end

    # Returns all children and children of children
    def descendants
      nodes = []
      children.each do |c|
        nodes << c
        nodes << c.descendants
      end
      nodes.flatten
    end

    # Returns the root node of the tree.
    def root
      node = self
      node = node.parent while node.parent
      node
    end

    # Checks if this node is a root
    def root?
      !parent_id
    end

    # Returns all siblings of the current node.
    #
    #   subchild1.siblings # => [subchild2]
    def siblings
      self_and_siblings - [self]
    end

    # Returns all siblings and a reference to the current node.
    #
    #   subchild1.self_and_siblings # => [subchild1, subchild2]
    def self_and_siblings
      parent ? parent.children : self.class.roots
    end

    # BUG: https://github.com/rails/rails/issues/14369
    # It's still a bug. Remove it to see failing test
    def parent_id=(id)
      self.parent = self.class.find_by(id: id)
    end

  end

end

ActiveSupport.on_load :active_record do
  include ComfortableMexicanSofa::ActsAsTree
end
