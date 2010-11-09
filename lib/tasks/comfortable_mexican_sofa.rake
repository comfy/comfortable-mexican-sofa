namespace :comfortable_mexican_sofa do
  
  namespace :import do
    
    task :check_for_requirements => :environment do |task, args|
      if !(@seed_path = ComfortableMexicanSofa.config.seed_data_path)
        abort('ComfortableMexicanSofa.config.seed_data_path is not set. Where are those yaml files?') 
      end
      if !(@site = CmsSite.find_by_hostname(args[:hostname]))
        abort("Can't find site with HOSTNAME '#{args[:hostname]}'")
      end
      puts "Starting import into #{@site.label} (#{@site.hostname})..."
    end
    
    desc 'Import layouts into database'
    task :layouts => [:environment, :check_for_requirements] do |task, args|
      puts 'Importing Layouts...'
      layouts = Dir.glob(File.expand_path("#{@site.hostname}/layouts/**/*.yml", @seed_path)).collect do |layout_file_path|
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
              layout.save!
              puts "Saved layout: #{layout.label} (#{layout.slug})"
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
      puts 'Importing Pages...'
      pages = Dir.glob(File.expand_path("#{@site.hostname}/pages/**/*.yml", @seed_path)).collect do |page_file_path|
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
              page.save!
              puts "Saved page: #{page.label} (#{page.full_path})"
            else
              puts "Skipping page: #{page.label} (#{page.full_path})"
            end
          else
            pages.push page
          end
        end
      end
    end
    
    desc 'Import snippets into database'
    task :snippets => [:environment, :check_for_requirements] do |task, args|
      puts 'Importing Snippets...'
      snippets = Dir.glob(File.expand_path("#{@site.hostname}/snippets/**/*.yml", @seed_path)).collect do |snippet_file_path|
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
            snippet.save!
            puts "Saved snippet: #{snippet.label} (#{snippet.slug})"
          else
            puts "Skipping snippet: #{snippet.label} (#{snippet.slug})"
          end
        end
      end
    end
    
    desc 'Import layouts, pages and snippets all in one go'
    task :all => [:layouts, :pages, :snippets]
    
  end
  
  namespace :export do
    
    desc 'Export layouts to yaml files'
    task :layouts => [:environment, :check_for_requirements] do |task, args|
      
    end
    
    desc 'Export pages to yaml files'
    task :pages => [:environment, :check_for_requirements] do |task, args|
      
    end
    
    desc 'Export snippets to yaml files'
    task :snippets => [:environment, :check_for_requirements] do |task, args|
      
    end
    
    desc 'Export layouts, pages and snippets all in one go'
    task :all => [:layouts, :pages, :snippets]
    
  end
end