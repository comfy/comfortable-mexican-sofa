Paperclip.options[:command_path] = case Rails.env
  when 'development' then "/usr/local/bin"  
end