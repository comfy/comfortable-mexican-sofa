Comfortable Mexican Sofa (CMS)
==============================

What is this?
-------------
ComfortableMexicanSofa is a micro CMS implemented as a Rails 3.* engine. This CMS is not a full-blown application like RadiantCMS. It's more like the ComatoseCMS, only more modern and infinitely more powerful and flexible. ComfortableMexicanSofa can function as a stand-alone installation, but it's designed to be used as an extension to your Rails application. If you have any (static) content that needs to be managed this CMS will handle it. 

This CMS also allows high level of integration. You can easily use page content anywhere within your app, and even use page content as renderable templates from inside your controllers. You may also reuse CMS's admin interface for your own admin backend.

Installation
------------
Add gem definition to your Gemfile:
    
    config.gem 'comfortable_mexican_sofa'
    
Then from the Rails project's root run:
    
    bundle install
    rails g cms
    rake db:migrate
    
At this point you should have database structure created, some assets copied to /public directory and initializer set up:
    
    ComfortableMexicanSofa.configure do |config|
      config.cms_title      = 'ComfortableMexicanSofa'
      config.authentication = 'ComfortableMexicanSofa::HttpAuth'
    end
    
    # Credentials for HttpAuth
    ComfortableMexicanSofa::HttpAuth.username = 'username'
    ComfortableMexicanSofa::HttpAuth.password = 'password'
    
Usage
-----
Now you should be able to navigate to http://yoursite/cms-admin

### Step 1: Create Site
CMS allows you to run multiple sites from a single installation. Each site is attached to a hostname. For the first time you'll be prompted to set up the initial site. Hostname will be pre-populated so just choose a label.

### Step 2: Create Layout
Before creating pages and populating them with content we need to create a layout. Layout is the template of your pages. It defines some reusable content (like header and footer, for example) and places where the content goes. A very simple layout can look like this:

    <html>
      <body>
        <h1>My Awesome Site</h1>
        {{ cms:page:content }}
      </body>
    </html>
    
So there's your layout and the `{{cms:page:content}}` defines a place where renderable `content` will go. There's just a handful of tags that you can use.

#### Page Blocks
pieces of content that will be output on the page:
    
    {{ cms:page:some_label:text }}      # will render a text area during page creation
                                        # alternatively you may use: {{ cms:page:some_label }}
    {{ cms:page:some_label:string }}    # will render a text field during page creation
    {{ cms:page:some_label:datetime }}  # datetime select widget
    {{ cms:page:some_label:integer }}   # a number field

#### Page Fields
pieces of content that are not rendered. They are useful for hidden values you want to use inside your app. `@cms_page` instance variable is available when you need to access field values.

    {{ cms:field:some_label:text }}     # text area for the page creation form
    {{ cms:field:some_label:string }}   # same as {{ cms:field:some_label }}, this is a text field
    {{ cms:field:some_label:datetime }} # datetime
    {{ cms:field:some_label:integer }}  # a number field

#### Snippets
bits of reusable content that can be used in pages and layouts
    
    {{ cms:snippet:snippet_slug }}
    
#### Helpers
are tags that map to your view helpers methods
    
    {{ cms:helper:method_name }}        # gets translated to <%= method_name( ) %>
    {{ cms:helper:method_name:x:y:z }}  # gets translated to <%= method_name('x', 'y', 'z') %>
    
#### Partials
are exactly that. You don't want to do IRB inside CMS so there's a handy tag:
    
    {{ cms:partial:path/to/partial }}     # gets translated to <%= render :partial => 'path/to/partial' %>
    {{ cms:partial:path/to/partial:x:y }} # gets translated to <%= render :partial => 'path/to/partial', 
                                          # :locals => { :param_1 => 'x', :param_2 => 'y'} %>

You don't have to define entire html layout, however. You can simply re-use your application one. Page content will be yielded into it like any normal view.

TODO: more stuff

### Step 3: Create Page

TODO: You pres butan page is created. Yay!
