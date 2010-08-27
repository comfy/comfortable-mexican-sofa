Paperclip.options[:command_path] = case Rails.env
  when 'development' then "/opt/local/bin"  
end