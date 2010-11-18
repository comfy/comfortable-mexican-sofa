module ComfortableMexicanSofa::ViewHooks
  
  # Array of declared hooks
  def self.hooks
    @@hooks ||= { }
  end
  
  # Renders hook content
  def self.render(name, template, options = {})
    if self.hooks[name.to_sym]
      template.render({:partial => self.hooks[name.to_sym]}.merge(options))
    end
  end
  
  # Will declare a partial that will be rendered for this hook
  # Example:
  # ComfortableMexicanSofa::ViewHooks.add(:navigation, 'shared/navigation')
  def self.add(name, partial_path)
    self.hooks[name.to_sym] = partial_path
  end
  
  # Removing previously declared hook
  def self.remove(name)
    self.hooks.delete(name)
  end
  
end