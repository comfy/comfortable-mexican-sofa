# frozen_string_literal: true

# This mechanism is used by 3rd party plugins.
# Normally you'd use partials from your own app
module ComfortableMediaSurfer::ViewHooks
  # Array of declared hooks
  def self.hooks
    @hooks ||= {}
  end

  # Renders hook content
  def self.render(name, template, options = {})
    out = ''
    (hooks[name.to_sym] || []).each do |path|
      out += template.render({ partial: path.first }.merge(options))
    end
    out.html_safe
  end

  # Will declare a partial that will be rendered for this hook
  # Example:
  # ComfortableMediaSurfer::ViewHooks.add(:navigation, 'shared/navigation')
  def self.add(name, partial_path, position = 0)
    hooks[name.to_sym] ||= []
    hooks[name.to_sym] << [partial_path, position]
    hooks[name.to_sym].sort_by!(&:last)
  end

  # Removing previously declared hook
  def self.remove(name)
    hooks.delete(name)
  end
end
