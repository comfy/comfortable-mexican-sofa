Paperclip.options[:command_path] = case Rails.env
  when 'development', 'test' then '/usr/local/bin'
end

if Rails.env.test?
  class Paperclip::Attachment
    def self.default_options 
      @default_options = {
        :url                    => "/system/:attachment/:id/:style/:filename",
        :path                   => ":rails_root/public:url",
        :styles                 => {},
        :only_process           => [],
        :processors             => [:thumbnail],
        :convert_options        => {},
        :source_file_options    => {},
        :default_url            => "/:attachment/:style/missing.png",
        :default_style          => :original,
        :storage                => :filesystem,
        :use_timestamp          => false,
        :whiny                  => Paperclip.options[:whiny] || Paperclip.options[:whiny_thumbnails],
        :use_default_time_zone  => true,
        :hash_digest            => "SHA1",
        :hash_data              => ":class/:attachment/:id/:style/:updated_at",
        :preserve_files         => false
      }
    end
  end
end