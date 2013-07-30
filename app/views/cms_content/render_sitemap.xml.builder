xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'

xml.urlset :xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9' do

  @cms_site.pages.published.each do |page|

    # Loop through any published variations of each page
    Cms::Variation.list.each do |variation|

      if page.has_variation?(variation)
        pc = page.page_content(variation)
        if pc.present?
          xml.url do 
            xml.loc "http://#{@cms_site.hostname}#{"/" + @cms_site.path unless @cms_site.path.blank? }#{pc.full_path}"
            # just take some guesses the closer to the root means higher priority
            # start subtracting 0.1 for every additional child page, max out at 0.1
            # "/" splits to 0, "/child_page" splits to 2, hence weird max -1 
            xml.priority [1 - (0.1 * ( ( [pc.full_path.split("/").count, 1].max - 1 ) ) ), 0.1].max
            xml.lastmod page.updated_at.strftime('%Y-%m-%d')
          end
        end
      end

    end

  end
end


