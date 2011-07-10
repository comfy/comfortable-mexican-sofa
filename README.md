# ComfortableMexicanSofa (CMS Engine) [![Build Status](https://secure.travis-ci.org/twg/comfortable-mexican-sofa.png)](http://travis-ci.org/twg/comfortable-mexican-sofa)

ComfortableMexicanSofa is a powerful CMS Engine for your Rails 3 applications. Unlike other CMS solutions ComfortableMexicanSofa compliments your application, it doesn't force you to extend it to implement custom functionality.

Features
--------
* Powerful page templating capability
* Simple integration with Rails 3.0 and 3.1 apps
* Multiple Sites from a single installation
* Multilingual
* Fixtures for initial content population
* Revision History
* Great reusable admin interface
* Almost no 3rd party library dependencies

Installation
------------
Add gem definition to your Gemfile:
    
    gem 'comfortable_mexican_sofa'
    
Then from the Rails project's root run:
    
    bundle install
    rails generate cms
    rake db:migrate
    
When upgrading from the older version please take a look at [Upgrading ComfortableMexicanSofa](https://github.com/twg/comfortable-mexican-sofa/wiki/Upgrading-ComfortableMexicanSofa)
    
Quick Start Guide
-----------------
After finishing installation you should be able to navigate to http://yoursite/cms-admin

Default username and password is 'username' and 'password'. You probably want to change it right away. Admin credentials (among other things) can be found and changed in the cms initializer: [/config/initializers/comfortable\_mexican\_sofa.rb](https://github.com/twg/comfortable-mexican-sofa/blob/master/config/initializers/comfortable_mexican_sofa.rb)

Before creating pages and populating them with content we need to create a Site. Site defines a hostname, content path and it's language.

After creating a Site, you need to make a Layout. Layout is the template of your pages; it defines some reusable content (like header and footer, for example) and places where the content goes. A very simple layout can look like this:
    
    <html>
      <body>
        <h1>{{ cms:page:header:string }}</h1>
        {{ cms:page:content:text }}
      </body>
    </html>

Once you have a layout, you may start creating pages and populating content. It's that easy.

![Sofa's Page Edit View](https://github.com/twg/comfortable-mexican-sofa/raw/master/doc/page_editing.png)

CMS Tags Overview
-----------------
There are a [number of cms tags]() that define where the content goes and how it's populated. **Page** and **Field** tags are used during layout creation. **Snippet**, **Helper** and **Partial** tags can be peppered pretty much anywhere. Tag is structured like so:
    
    {{ cms:page:content:text }}
        \    \     \      \ 
         \    \     \      ‾ tag format or extra attributes
          \    \     ‾‾‾‾‾‾‾ label/slug/path for the tag, 
           \    ‾‾‾‾‾‾‾‾‾‾‾‾ tag type (page, field, snippet, helper, partial)
            ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ cms tag identifier
           
Here's a number of tag variations:
    
    # Page tags are pieces of text content that will get rendered on the page. Format defines how form field
    # gets rendered in the page editing/creation section of the admin area.
    
    {{ cms:page:some_label:text }}
    {{ cms:page:some_label }}             # shorthand for above. 'text' is default format for pages
    {{ cms:page:some_label:string }}      # in admin area text field is displayed instead of textarea
    {{ cms:page:some_label:datetime }}    # similarly, datetime widget in the admin area
    {{ cms:page:some_label:integer }}     # a number field
    {{ cms:page:some_label:rich_text }}   # wymiwyg editor will be used to edit this content
    
    # Field tags are pieces of text content that are NOT rendered on the page. They can be accessed via
    # your application's layout / helpers / partials etc. Useful for populating this like <meta> tags.
    # Field formats are exactly the same as for Page tags.
    
    {{ cms:field:some_label:string }}
    {{ cms:field:some_label }}            # same as above. 'string' is default format for fields
    
    # Snippet tags are bits or reusable content that can be used anywhere. Imagine creating content like
    # a sharing widget, or business address that you want to randomly use across your site.
    
    {{ cms:snippet:some_label }}
    
    # Helper is a wrapper for your regular helpers. Normally you cannot have IRB in CMS content, so there are
    # tags that allow calling helpers and partials.
    
    {{ cms:helper:method_name }}          # same as <%= method_name() %>
    {{ cms:helper:method_name:x:y:z }}    # same as <%= method_name('x', 'y', 'z') %>
    
    # Partial tags are wrappers just like above helper ones.
    
    {{ cms:partial:path/to/partial }}     # same as <%= render :partial => 'path/to/partial' %>
    {{ cms:partial:path/to/partial:a:b }} # same as <%= render :partial => 'path/to/partial',
                                          #   :locals => { :param_1 => 'a', :param_1 => 'b' } %>

Multiple Sites
--------------
Sofa is able to manage multiple sites from the same application. For instance: 'site-a.example.com' and 'site-b.example.com' will have distinct set of layouts, pages, snippets, etc. To enable multi-site functionality make sure you have this setting in the initializer: `config.enable_multiple_sites = true`.
    
Integrating CMS with your app
-----------------------------
ComfortableMexicanSofa is a plugin, so it allows you to easily access content it manages. Here's some things you can do.

You can use your existing application layout. When creating CMS layouts there's an option to use an application layout. Suddenly all CMS pages using that layout will be rendered through <%= yield %> of your application layout.

You can use CMS pages as regular views:
    
    def show
      @dinosaur = Dinosaur.find(params[:id])
      # CMS page probably should have either helper or partial tag to display @dinosaur details
      render :cms_page => '/dinosaur
    end
    
Actually, you don't need to explicitly render a CMS page like that. Sofa will try to rescue a TemplateNotFound by providing a matching CMS page.

You can access **Page** or **Field** tag content directly from your application (layouts/helpers/partials) via `cms_page_content` method. This is how you can pull things like meta tags into your application layout.
    
    # if @cms_page is available (meaning Sofa is doing the rendering)
    cms_page_content(:page_or_field_label)
    
    # anywhere else
    cms_page_content(:page_or_field_label, CmsPage.find_by_slug(...))
    
Similarly you can access **Snippet** content:
    
    cms_snippet_content(:snippet_slug)
    
You can also directly access `@cms_site`, `@cms_layout` and `@cms_page` objects from helpers, partials and application layouts used in rendering of a CMS page.
    
Extending Admin Area
--------------------

If you wish, you can re-use Sofa's admin area for things you need to administer in your application. To do this, first you will need to make your admin controllers to inherit from CmsAdmin::BaseController. This way, your admin views will be using Sofa's admin layout and it's basic HttpAuth.
    
    class Admin::CategoriesController < CmsAdmin::BaseController
      # your code goes here
    end
    
From your views you can use `cms_form_for` method to re-use Sofa's FormBuilder. There are also some existing styles for tables, will\_paginate helpers, etc. Take a look in [/public/stylesheets/comfortable\_mexican\_sofa/content.css](https://github.com/twg/comfortable-mexican-sofa/blob/master/public/stylesheets/comfortable_mexican_sofa/content.css)

You will probably want to add a navigation link on the left side, and for that you will want to use ViewHook functionality. Create a partial that has a link to your admin area and declare in Sofa's initializer: `ComfortableMexicanSofa::ViewHooks.add(:navigation, '/admin/navigation')`. Similarly you can add extra stylesheets, etc into admin area in the same way.
    
Do you have other authentication system in place (like Devise, AuthLogic, etc) and wish to use that? For that, you will need to create a module that does the authentication check and make ComfortableMexicanSofa use it. For example:
    
    module CmsDeviseAuth
      def authenticate
        unless current_user && current_user.admin?
          redirect_to new_user_session_path
        end
      end
    end
    
You can put this module in /config/initializers/comfortable\_mexican\_sofa.rb and change authentication method: `config.authentication = 'CmsDeviseAuth'`. Now to access Sofa's admin area users will be authenticated against your existing authentication system.

![Looks pretty comfortable to me. No idea what makes it Mexican.](https://github.com/twg/comfortable-mexican-sofa/raw/master/doc/sofa.png)

ComfortableMexicanSofa is released under the [MIT license](https://github.com/twg/comfortable-mexican-sofa/raw/master/LICENSE) 

Copyright 2009-2011 Oleg Khabarov, [The Working Group Inc](http://www.twg.ca)