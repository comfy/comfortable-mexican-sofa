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
    
For a full list of available configuration options and their defaults take a peek in here: [configuration.rb](http://https://github.com/theworkinggroup/comfortable-mexican-sofa/blob/master/lib/comfortable_mexican_sofa/configuration.rb)
    
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

Layout may also be linked to the `application layout`. As a result cms page content will end up inside `<%= yeild %>` of your application layout.

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

### Step 3: Create Page
Now you're ready to create a page. Based on how you defined your layout, you should have form inputs ready to be populated.
Save a page, and it will be accessible from the public side.

Working with fixtures
---------------------
During development it's often more convenient to work with files that can be source controlled, versus putting content in the database and then manage database dump. Thankfully Sofa makes working with fixtures easy.

### Setting up Fixtures
First of all you need to set a path where fixture files will be found:
    
    # in config/initializers/comfortable_mexican_sofa.rb
    if Rails.env.development? || Rails.env.test?
      ComfortableMexicanSofa.config.seed_data_path = File.expand_path('db/cms_seeds', Rails.root)
    end
    
This is an example of the file/folder structure for fixtures:
    
    your-site.local/
      - layouts/
        - default_layout.yml
      - pages
        - index.yml
        - help.yml
        - help/
          - more_help.yml
      - snippets
        - random_snippet.yml
    
Then it's a matter of populating the content. Few rules to remember:
  
- root page is always index.yml
- sections of the page are defined by cms\_block\_attributes
- parent pages are identified by full_path (slug for layouts)
- folder structure reflects tree structure of the site

Example fixture files for a [layout](https://github.com/theworkinggroup/comfortable-mexican-sofa/blob/master/test/cms_seeds/test.host/layouts/nested.yml), [page](https://github.com/theworkinggroup/comfortable-mexican-sofa/blob/master/test/cms_seeds/test.host/pages/child/subchild.yml) and [snippet](https://github.com/theworkinggroup/comfortable-mexican-sofa/blob/master/test/cms_seeds/test.host/snippets/default.yml)

**Note:** If ComfortableMexicanSofa.config.seed\_data\_path is set no content is loaded from database. Only fixture files are used.

### Importing fixtures into database
Now that you have all those fixture files, how do we get them into database? Easy:

    rake comfortable_mexican_sofa:import:all FROM=your-site.local TO=your-site.com PATH=/path/to/fixtures
    
PATH is optional if seed\_data\_path configuration option is set.

### Exporting database data into fixtures
If you need to pull down database content into fixtures it's done as follows:
    
    rake comfortable_mexican_sofa:export:all FROM=your-site.com TO=your-site.local PATH=/path/to/fixtures
    
During import/export it will prompt you if there are any files/database entries that are going to be overwritten

Admin Area Integration
----------------------
Sofa has a wonderful admin area. Why would you want to make your own layout, styling and so on if you can reuse what CMS has. 

You can easily make your controllers use layouts and CMS authentication like this:

    class Admin::UsersController < CmsAdmin::BaseController
      # ...
    end
    
To add your own tabs to the admin area you can use hooks:
    
    # in config/initializers/comfortable_mexican_sofa.rb
    ComfortableMexicanSofa::ViewHooks.add(:navigation, '/path/to/view/partial')
    ComfortableMexicanSofa::ViewHooks.add(:html_head, '/path/to/view/partial')
