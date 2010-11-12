namespace :comfortable_mexican_sofa do
  
  # Example use:
  #   rake comfortable_mexican_sofa:import:all FROM=mysite.local TO=mysite.com PATH=/path/to/seed_data
  namespace :import do
    
    task :check_for_requirements => :environment do |task, args|
      @from       = args[:from].present?? args[:from] : nil
      @site       = args[:to].present?? args[:to] : nil
      @seed_path  = (args[:seeds].present?? args[:seeds] : nil) || ComfortableMexicanSofa.config.seed_data_path
      
      if !@seed_path
        abort 'PATH is not set. Please define where cms fixtures are located.'
      end
      unless File.exists?((@from && @seed_path = "#{@seed_path}/#{@from}").to_s)
        abort "FROM is not properly set. Cannot find fixtures in '#{@seed_path}'"
      end
      if !(@site = CmsSite.find_by_hostname(args[:to]))
        abort "TO is not properly set. Cannot find site with hostname '#{args[:to]}'"
      end
      puts "Starting import into #{@site.label} (#{@site.hostname}) from '#{@seed_path}'"
    end
    
    desc 'Import layouts into database'
    task :layouts => [:environment, :check_for_requirements] do |task, args|
      puts 'Importing Layouts'
      puts '-----------------'
      layouts = Dir.glob(File.expand_path('layouts/*.yml', @seed_path)).collect do |layout_file_path|
        attributes = YAML.load_file(layout_file_path).symbolize_keys!
        @site.cms_layouts.load_for_slug!(@site, attributes[:slug])
      end
      
      CmsPage.connection.transaction do
        # Fixtures are not ordered in any particular way. Saving order matters,
        # so we cycle them until there nothing left to save
        while layouts.present?
          layout = layouts.shift
          if !layout.parent || layout.parent && parent = @site.cms_layouts.find_by_slug(layout.parent.slug)
            layout.parent = (parent rescue nil)
            should_write    = true
            existing_layout = nil
            
            if existing_layout = @site.cms_layouts.find_by_slug(layout.slug)
              print "Found layout in database with slug: #{layout.slug}. Overwrite? (yN): "
              should_write = ($stdin.gets.to_s.strip.downcase == 'y')
            end
            if should_write
              if existing_layout
                existing_layout.attributes = layout.attributes.slice('label', 'content', 'css', 'js')
                layout = existing_layout
              end
              puts "Saving layout: #{layout.label} (#{layout.slug})"
              layout.save!
            else
              puts "Skipping layout: #{layout.label} (#{layout.slug})"
            end
          else
            layouts.push layout
          end
        end
      end
    end
    
    desc 'Import pages into database'
    task :pages => [:environment, :check_for_requirements] do |task, args|
      puts 'Importing Pages'
      puts '---------------'
      pages = Dir.glob(File.expand_path('pages/**/*.yml', @seed_path)).collect do |page_file_path|
        attributes = YAML.load_file(page_file_path).symbolize_keys!
        @site.cms_pages.load_for_full_path!(@site, attributes[:full_path])
      end
      CmsPage.connection.transaction do
        # Fixtures are not ordered in any particular way. Saving order matters,
        # so we cycle them until there nothing left to save
        while pages.present?
          page = pages.shift
          if !page.parent || page.parent && parent = @site.cms_pages.find_by_full_path(page.parent.full_path)
            page.parent = (parent rescue nil)
            page.cms_layout = @site.cms_layouts.find_by_slug(page.cms_layout.slug)
            should_write  = true
            existing_page = nil
            
            if existing_page = @site.cms_pages.find_by_full_path(page.full_path)
              print "Found page in database with full_path: #{page.full_path}. Overwrite? (yN): "
              should_write = ($stdin.gets.to_s.strip.downcase == 'y')
            end
            
            if should_write
              if existing_page
                # merging cms_blocks_attributes with the existing page
                attrs = page.cms_blocks_attributes.collect do |block_attrs|
                  existing_block = existing_page.cms_blocks_attributes.find{|b| b[:label] == block_attrs[:label]}
                  block_attrs[:id] = existing_block[:id] if existing_block
                  block_attrs.stringify_keys
                end
                
                existing_page.attributes = page.attributes.slice('label')
                existing_page.cms_blocks_attributes = attrs
                page = existing_page
              end
              puts "... Saving page: #{page.label} (#{page.full_path})"
              page.save!
            else
              puts "... Skipping page: #{page.label} (#{page.full_path})"
            end
          else
            pages.push page
          end
        end
      end
    end
    
    desc 'Import snippets into database'
    task :snippets => [:environment, :check_for_requirements] do |task, args|
      puts 'Importing Snippets'
      puts '------------------'
      snippets = Dir.glob(File.expand_path('snippets/*.yml', @seed_path)).collect do |snippet_file_path|
        attributes = YAML.load_file(snippet_file_path).symbolize_keys!
        @site.cms_snippets.load_for_slug!(@site, attributes[:slug])
      end
      CmsSnippet.connection.transaction do
        snippets.each do |snippet|
          should_write      = true
          existing_snippet  = nil
          if existing_snippet = @site.cms_snippets.find_by_slug(snippet.slug)
            print "Found snippet in database with slug: #{snippet.slug}. Overwrite? (yN): "
            should_write = ($stdin.gets.to_s.strip.downcase == 'y')
          end
          if should_write
            if existing_snippet
              existing_snippet.attributes = snippet.attributes.slice('label', 'content')
              snippet = existing_snippet
            end
            puts "... Saving snippet: #{snippet.label} (#{snippet.slug})"
            snippet.save!
          else
            puts "... Skipping snippet: #{snippet.label} (#{snippet.slug})"
          end
        end
      end
    end
    
    desc 'Import layouts, pages and snippets all in one go'
    task :all => [:layouts, :pages, :snippets]
    
  end
  
  # Example use:
  #   rake comfortable_mexican_sofa:import:all FROM=mysite.com TO=mysite.local PATH=/path/to/seed_data
  namespace :export do
    
    task :check_for_requirements => :environment do |task, args|
      @site       = args[:from].present?? args[:from] : nil
      @to         = args[:to].present?? args[:to] : nil
      @seed_path  = (args[:seeds].present?? args[:seeds] : nil) || ComfortableMexicanSofa.config.seed_data_path
      
      if !@seed_path
        abort 'PATH is not set. Please define where cms fixtures are located.'
      end
      if !(@site = CmsSite.find_by_hostname(args[:from]))
        abort "FROM is not properly set. Cannot find site with hostname '#{args[:from]}'"
      end
      unless @to && @seed_path = "#{@seed_path}/#{@to}"
        abort "TO is not properly set. What's the target hostname?"
      end
      
      FileUtils.mkdir_p @seed_path
      FileUtils.mkdir_p "#{@seed_path}/layouts"
      FileUtils.mkdir_p "#{@seed_path}/pages"
      FileUtils.mkdir_p "#{@seed_path}/snippets"
      
      puts "Starting export from #{@site.label} (#{@site.hostname}) to '#{@seed_path}'"
    end
    
    desc 'Export layouts to yaml files'
    task :layouts => [:environment, :check_for_requirements] do |task, args|
      puts 'Exporting Layouts'
      puts '-----------------'
      CmsLayout.all.each do |layout|
        should_write = true
        file_path = File.join(@seed_path, 'layouts', "#{layout.slug}.yml")
        if File.exists?(file_path)
          print "Found layout fixture: #{file_path} Overwrite? (yN): "
          should_write = ($stdin.gets.to_s.strip.downcase == 'y')
        end
        if should_write
          attributes = layout.attributes.slice('label', 'slug', 'content', 'css', 'js')
          attributes['parent'] = layout.parent.slug if layout.parent
          open(file_path, 'w') do |f|
            f.write(attributes.to_yaml)
          end
          puts "... Saving layout: #{layout.label} (#{layout.slug})"
        else
          puts "... Skipping layout: #{layout.label} (#{layout.slug})"
        end
      end
    end
    
    desc 'Export pages to yaml files'
    task :pages => [:environment, :check_for_requirements] do |task, args|
      puts 'Exporting Pages'
      puts '---------------'
      CmsPage.all.each do |page|
        should_write = true
        page_name = page.full_path.split('/').last || 'index'
        page_path = (p = page.full_path.split('/')) && p.pop && p.join('/')
        
        FileUtils.mkdir_p "#{@seed_path}/pages/#{page_path}"
        file_path = File.join(@seed_path, 'pages', "#{page_path}/#{page_name}.yml")
        
        if File.exists?(file_path)
          print "Found page fixture: #{file_path} Overwrite? (yN): "
          should_write = ($stdin.gets.to_s.strip.downcase == 'y')
        end
        if should_write
          
          attributes = page.attributes.slice('label', 'slug', 'full_path')
          attributes['parent']                = page.parent.full_path if page.parent
          attributes['cms_layout']            = page.cms_layout.slug
          attributes['cms_blocks_attributes'] = page.cms_blocks_attributes.collect{|b| b.delete(:id) && b.stringify_keys}
          
          open(file_path, 'w') do |f|
            f.write(attributes.to_yaml)
          end
          puts "... Saving page: #{page.label} (#{page.full_path})"
        else
          puts "... Skipping page: #{page.label} (#{page.full_path})"
        end
      end
    end
    
    desc 'Export snippets to yaml files'
    task :snippets => [:environment, :check_for_requirements] do |task, args|
      puts 'Exporting Snippets'
      puts '------------------'
      CmsSnippet.all.each do |snippet|
        should_write = true
        file_path = File.join(@seed_path, 'snippets', "#{snippet.slug}.yml")
        if File.exists?(file_path)
          print "Found snippet fixture: #{file_path} Overwrite? (yN): "
          should_write = ($stdin.gets.to_s.strip.downcase == 'y')
        end
        if should_write
          attributes = snippet.attributes.slice('label', 'slug', 'content')
          open(file_path, 'w') do |f|
            f.write(attributes.to_yaml)
          end
          puts "... Saving snippet: #{snippet.label} (#{snippet.slug})"
        else
          puts "... Skipping snippet: #{snippet.label} (#{snippet.slug})"
        end
      end
    end
    
    desc 'Export layouts, pages and snippets all in one go'
    task :all => [:layouts, :pages, :snippets]
    
  end
end