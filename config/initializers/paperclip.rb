defined?(Paperclip) && Paperclip.options[:command_path] = case Rails.env
  when 'development', 'test' then '/usr/local/bin'
end