class Comfy::Cms::Page::Translation < Comfy::Cms::Translation
  cms_has_slug

  belongs_to :target_page,
    :class_name => 'Comfy::Cms::Page'

  validates :slug,
    presence: true,
    uniqueness: { scope: :translateable_id },
    unless: lambda{ |t| t.translateable && t.translateable.root? }
  validate :validate_target_page

  after_save :sync_child_translation_full_paths!, if: :full_path_changed?

  delegate :layout, to: :translateable

  protected
    def assign_full_path
      return unless translateable
      parent = (translateable.parent && translateable.parent.translations.find_by_locale(locale)) || translateable.parent
      self.full_path = parent ? "#{CGI::escape(parent.full_path).gsub('%2F', '/')}/#{slug}".squeeze('/') : '/'
    end

    def sync_child_translation_full_paths!
      translateable.children.each do |child|
        child.translations.where(locale: locale).each do |child_trans|
          child_trans.update_column(:full_path, child_trans.send(:assign_full_path))
          child_trans.send(:sync_child_translation_full_paths!)
        end
      end
    end

    def validate_target_page
      return unless self.target_page
      p = self
      while p.target_page do
        return self.errors.add(:target_page_id, 'Invalid Redirect') if (p = p.target_page) == self.translateable
      end
    end
end
