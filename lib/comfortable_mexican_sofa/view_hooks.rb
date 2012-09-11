module ComfortableMexicanSofa::ViewHooks
  
  # Array of declared hooks
  def self.hooks
    @@hooks ||= { }
  end
  
  # Renders hook content
  def self.render(name, template, options = {})
    out = ''
    (self.hooks[name.to_sym] || []).each do |path|
      out += template.render({:partial => path.first}.merge(options))
    end
    return out.html_safe
  end
  
  # Will declare a partial that will be rendered for this hook
  # Example:
  # ComfortableMexicanSofa::ViewHooks.add(:navigation, 'shared/navigation')
  def self.add(name, partial_path, position = 0)
    self.hooks[name.to_sym] ||= []
    self.hooks[name.to_sym] << [partial_path, position]
    self.hooks[name.to_sym].sort_by! { |hook| hook.last }
  end

  
  # Removing previously declared hook
  def self.remove(name)
    self.hooks.delete(name)
  end

end
