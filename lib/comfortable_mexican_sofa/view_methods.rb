module ComfortableMexicanSofa::ViewMethods

  def self.cms_block_tag(identifier, blockable)
    blockable && (block = blockable.blocks.find_by_identifier(identifier)) && block.tag
  end

  module Helpers
    # Wrapper around ComfortableMexicanSofa::FormBuilder
    def comfy_form_for(record, options = {}, &proc)
      options[:builder] = ComfortableMexicanSofa::FormBuilder
      options[:layout] ||= :horizontal
      bootstrap_form_for(record, options, &proc)
    end

    # Injects some content somewhere inside cms admin area
    def cms_hook(name, options = {})
      ComfortableMexicanSofa::ViewHooks.render(name, self, options)
    end

    # Content of a snippet. Examples:
    #   cms_snippet_content(:my_snippet)
    #   <%= cms_snippet_content(:my_snippet) do %>
    #     Default content can go here.
    #   <% end %>
    def cms_snippet_content(identifier, cms_site = @cms_site, &block)
      unless cms_site
        host, path = request.host.downcase, request.fullpath if respond_to?(:request) && request
        cms_site = Comfy::Cms::Site.find_site(host, path)
      end
      return '' unless cms_site

      snippet = cms_site.snippets.find_by_identifier(identifier)

      if !snippet && block_given?
        snippet = cms_site.snippets.create(
          :identifier => identifier,
          :label      => identifier.to_s.titleize,
          :content    => capture(&block)
        )
      end

      snippet ? snippet.content : ''
    end

    # Same as cms_snippet_content but cms tags will be expanded
    def cms_snippet_render(identifier, cms_site = @cms_site, &block)
      return '' unless cms_site
      content = cms_snippet_content(identifier, cms_site, &block)
      render :inline => ComfortableMexicanSofa::Tag.process_content(
        cms_site.pages.build, ComfortableMexicanSofa::Tag.sanitize_irb(content)
      )
    end

    # Content of a page block. This is how you get content from page:field
    # Example:
    #   cms_block_content(:left_column, CmsPage.first)
    #   cms_block_content(:left_column) # if @cms_page is present
    def cms_block_content(identifier, blockable = @cms_page)
      return '' unless tag = ComfortableMexicanSofa::ViewMethods.cms_block_tag(identifier, blockable)
      tag.content
    end

    # For those times when we need to render content that shouldn't be renderable
    # Example: {{cms:field}} tags
    def cms_block_content_render(identifier, blockable = @cms_page)
      return '' unless tag = ComfortableMexicanSofa::ViewMethods.cms_block_tag(identifier, blockable)
      render :inline => ComfortableMexicanSofa::Tag.process_content(blockable, tag.content)
    end

    # Same as cms_block_content but with cms tags expanded
    def cms_block_render(identifier, blockable = @cms_page)
      return '' unless tag = ComfortableMexicanSofa::ViewMethods.cms_block_tag(identifier, blockable)
      render :inline => ComfortableMexicanSofa::Tag.process_content(blockable, tag.render)
    end

    def current_status(page)
      if page.state == 'scheduled'
        if page.scheduled_on <= Time.current
          'Published'
        else
          if page.active_revision.present?
            'Published | Scheduled'
          else
            'Scheduled'
          end
        end
      else
        {
          unsaved: 'Unsaved',
          draft: 'Draft',
          published: 'Published',
          published_being_edited: 'Published | Draft',
          unpublished: 'Unpublished'
        }[page.state.to_sym]
      end
    end

    def page_category_list(page)
      displayed_string = page.categories.first.label if page.categories.first
      displayed_string += ", ..." if page.categories.second
      displayed_string
    end

    def user_list(label)
      Comfy::Cms::User.all.inject([[label, nil]]) do |list, user|
        list << [user.email]
      end
    end

    def category_list(label, cms_site = @site)
      cms_site.categories.of_type('Comfy::Cms::Page').inject([[label, nil]]) do |list, category|
        list << [category.label]
      end
    end

    def layout_list(label, cms_site = @site)
      cms_site.layouts.inject([[label, nil]]) do |list, layout|
        list << [layout.label, layout.identifier]
      end
    end

    # States offered to users don't map directly to internal states
    # used in the state machine. These should all match scopes defined
    # in the page model.
    def pseudo_state_list(label)
      [
        [label, nil],
        ['Draft (new)', 'draft'],
        ['Draft (new versions)', 'published_being_edited'],
        ['Published', 'published'],
        ['Scheduled', 'scheduled'],
        ['Unpublished', 'unpublished']
      ]
    end

  end

  ActionView::Base.send :include, ComfortableMexicanSofa::ViewMethods::Helpers
end
