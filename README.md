Comfortable Mexican Sofa (CMS)
==============================

What is this?
-------------
Comfortable Mexican Sofa is a Content Management System with an obnoxious name. Also it's a Rails 3 Engine. This means that you can use it as a stand-alone application and also as an Engine for your existing application.

Installation
------------

### Stand-alone
TODO: Need to create some sort of setup, so you can simply run:
    
    $ comfortable_mexican_sofa my_new_app
    
### As a Rails Engine
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
        { cms:page:content }
      </body>
    </html>
    
So there's your layout and the `{cms:page:content}` defines a place where renderable `content` will go. There's just a handful of tags that you can use.

**Page Blocks** are pieces of content that will be output on the page:

<dl>
  <dt><em>{ cms:page:some_label:text }</em></dt>
  <dd>alternatively <em>{ cms:page:some_label }</em>, will render a text area during page creation</dd>
  
  <dt><em>{ cms:page:some_label:string }</em></dt>
  <dd>will render a text field during page creation</dd>
  
  <dt><em>{ cms:page:some_label:datetime }</em></dt>
  <dd>datetime select widget</dd>
  
  <dt><em>{ cms:page:some_label:integer }</em></dt>
  <dd>a number field</dd>
</dl>

**Page Fields** are pieces of content that are not rendered. They are useful for hidden values you want to use inside your app. `@cms_page` instance variable is available when you need to access field values.

<dl>
  <dt><em>{ cms:field:some_label:text }</em></dt>
  <dd>text area for the page creation form</dd>
  
  <dt><em>{ cms:field:some_label:string }</em></dt>
  <dd>same as <em>{ cms:field:some_label }</em>, this is a text field</dd>
  
  <dt><em>{ cms:field:some_label:datetime }</em></dt>
  <dd>datetime</dd>
  
  <dt><em>{ cms:field:some_label:integer }</em></dt>
  <dd>a number field</dd>
</dl>

**Snippets** bits of reusable content that can be used in pages and layouts

<dl>
  <dt><em>{ cms:snippet:snippet_slug }</em></dt>
  <dd></dd>
</dl>

**Helpers** are tags that map to your view helpers methods

<dl>
  <dt><em>{ cms:helper:method_name }</em></dt>
  <dd>gets translated to method_name( )</dd>
  
  <dt><em>{ cms:helper:method_name:value_a:value_b }</em></dt>
  <dd>gets translated to method_name('value_a', 'value_b')</dd>
</dl>

**Partials** are exactly that. You don't want to do IRB inside CMS so there's a handy tag:

<dl>
  <dt><em>{ cms:partial:path/to/partial }</em></dt>
  <dd>gets translated to render :partial => 'path/to/partial'</dd>
  
  <dt><em>{ cms:partial:path/to/partial:value_a:value_b }</em></dt>
  <dd>gets translated to render :partial => 'path/to/partial', :locals => { :param_1 => 'value_a', :param_2 => 'value_b'}</dd>
</dl>

You don't have to define entire html layout, however. You can simply re-use your application one. Page content will be yielded into it like any normal view.

TODO: more stuff

### Step 3: Create Page

TODO: You pres butan page is created. Yay!
