# frozen_string_literal: true

module ComfortableMediaSurfer::Extensions::HasRevisions
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def cms_has_revisions_for(*fields)
      include ComfortableMediaSurfer::Extensions::HasRevisions::InstanceMethods

      attr_accessor :revision_data

      has_many :revisions,
               as: :record,
               dependent: :destroy,
               class_name: 'Comfy::Cms::Revision'

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
      return if new_record?

      if (respond_to?(:fragments_attributes_changed) && fragments_attributes_changed) ||
         !!changed.intersect?(revision_fields)
        self.revision_data = revision_fields.each_with_object({}) do |field, c|
          c[field] = send("#{field}_was")
        end
      end
    end

    # Revision is created only if relevant data changed
    def create_revision
      return unless revision_data

      limit = ComfortableMediaSurfer.config.revisions_limit.to_i

      # creating revision
      if limit != 0
        revisions.create!(data: revision_data)
      end

      # blowing away old revisions
      ids = [0] + revisions.order(created_at: :desc).limit(limit).pluck(:id)
      revisions.where('id NOT IN (?)', ids).destroy_all
    end

    # Assigning whatever is found in revision data and attempting to save the object
    def restore_from_revision(revision)
      return unless revision.record == self

      update!(revision.data)
    end
  end
end

ActiveSupport.on_load :active_record do
  include ComfortableMediaSurfer::Extensions::HasRevisions
end
