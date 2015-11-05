def load_gem_configs
  if defined?(Rails)
    mas_build_config_file = "#{::Rails.root}/config/mas-build"
    require_relative(mas_build_config_file) if File.exists?(mas_build_config_file + '.rb')
  end
end

def run(command)
  sh command
  raise "Error executing #{command}" unless $? == 0
end

def gem_name_to_module name
  name.split('-').map do |namespace|
    if namespace == 'mas'
      'MAS'
    else
      namespace.split('_').map do |word|
        word.capitalize
      end.join
    end
  end.join('::')
end

namespace :gem do
  desc "Build gem using it's version and build number"
  task :build do
    load_gem_configs

    gemspec_file_list = Dir.glob('*.gemspec')
    raise 'Gemspec not found or multiple' unless gemspec_file_list.length == 1

    build_number = ENV['GO_PIPELINE_COUNTER'] || ENV['CI_PIPELINE_COUNTER']
    raise 'Build number not specified' unless build_number

    gemspec_filename = gemspec_file_list.first
    gemspec = Kernel.eval(IO.read(gemspec_filename))

    version = gemspec.version.to_s
    build_version = "#{version}.#{build_number}"
    puts "Building version #{build_version}"

    gemspec.version = Gem::Version.new(build_version)
    gemspec_updated_content = gemspec.to_ruby
    File.open(gemspec_filename, 'w') { |file| file.puts gemspec_updated_content }
    puts "#{gemspec_filename} changed"

    unless system("gem build #{gemspec_filename}")
      raise "Gem couldn't be build"
    end


    tag = "v#{build_version}"
    tag_exists = `git tag -l #{tag}` != ''

    if tag_exists
      # 1. If a tag already exists for the current version, raise an error if it points to a different commit
      tag_points_to = `git rev-list #{tag} | head -n1`
      head_hash = `git rev-parse HEAD`
      raise "Tag #{tag} already exists, but points to a different commit!" unless tag_points_to == head_hash
    else
      # 2. If a tag doesn't exist for the current version, then create one.
      create_and_push_tag = "git tag -a #{tag} -m 'Version #{build_version} (tagged by mas-build)' && git push --tags"
      raise "Could not create git tag #{tag} for version #{build_version}" unless system(create_and_push_tag)
    end
  end
end
