# ComfortableMexicanSofa
[![Gem Version](https://badge.fury.io/rb/comfortable_mexican_sofa.png)](http://rubygems.org/gems/comfortable_mexican_sofa) [![Build Status](https://travis-ci.org/comfy/comfortable-mexican-sofa.png?branch=master)](https://travis-ci.org/comfy/comfortable-mexican-sofa) [![Dependency Status](https://gemnasium.com/comfy/comfortable-mexican-sofa.png)](https://gemnasium.com/comfy/comfortable-mexican-sofa) [![Code Climate](https://codeclimate.com/github/comfy/comfortable-mexican-sofa.png)](https://codeclimate.com/github/comfy/comfortable-mexican-sofa) [![Coverage Status](https://coveralls.io/repos/comfy/comfortable-mexican-sofa/badge.png?branch=master)](https://coveralls.io/r/comfy/comfortable-mexican-sofa)

ComfortableMexicanSofa is a powerful CMS Engine for your Rails 4 applications.

Features
--------
* Simple integration with Rails 4 apps
* Build your application in Rails, not in CMS
* Powerful page templating capability using [Tags](https://github.com/comfy/comfortable-mexican-sofa/wiki/Tags)
* [Multiple Sites](https://github.com/comfy/comfortable-mexican-sofa/wiki/Sites) from a single installation
* Multilingual
* [Fixtures](https://github.com/comfy/comfortable-mexican-sofa/wiki/Working-with-CMS-fixtures) for initial content population
* [Revision History](https://github.com/comfy/comfortable-mexican-sofa/wiki/Revisions)
* [Great extendable admin interface](https://github.com/comfy/comfortable-mexican-sofa/wiki/Reusing-sofa%27s-admin-area) built with [Bootstrap](http://twitter.github.com/bootstrap/), [CodeMirror](http://codemirror.net/) and [WYSIHTML5](http://xing.github.com/wysihtml5/)

Installation
------------
Add gem definition to your Gemfile:
    
```ruby
gem 'comfortable_mexican_sofa', '~> 1.11.0'
``` 

Then from the Rails project's root run:
    
    bundle install
    rails generate comfy:cms
    rake db:migrate
    
Now take a look inside your `config/routes.rb` file. You'll see where routes attach for the admin area and content serving. Make sure that content serving route appears as a very last item.

```ruby
comfy_path :cms_admin, :path => '/admin'
comfy_path :cms, :path => '/', :sitemap => false
```

When upgrading from the older version please take a look at [Upgrading ComfortableMexicanSofa](https://github.com/comfy/comfortable-mexican-sofa/wiki/Upgrading-ComfortableMexicanSofa)

Installation for Rails 3
------------------------
For Rails 3 apps feel free to use [1.8 release](https://github.com/comfy/comfortable-mexican-sofa/tree/1.8)
    
```ruby
gem 'comfortable_mexican_sofa', '~> 1.8.0'
```

Quick Start Guide
-----------------
After finishing installation you should be able to navigate to http://yoursite/cms-admin

Default username and password is 'username' and 'password'. You probably want to change it right away. Admin credentials (among other things) can be found and changed in the cms initializer: [/config/initializers/comfortable\_mexican\_sofa.rb](https://github.com/comfy/comfortable-mexican-sofa/blob/master/config/initializers/comfortable_mexican_sofa.rb)

Before creating pages and populating them with content we need to create a Site. Site defines a hostname, content path and it's language.

After creating a Site, you need to make a Layout. Layout is the template of your pages; it defines some reusable content (like header and footer, for example) and places where the content goes. A very simple layout can look like this:
    
```html
<html>
  <body>
    <h1>{{ cms:page:header:string }}</h1>
    {{ cms:page:content:text }}
  </body>
</html>
```

Once you have a layout, you may start creating pages and populating content. It's that easy.

For more information please [see Wiki pages](https://github.com/comfy/comfortable-mexican-sofa/wiki).

![Sofa's Page Edit View](https://github.com/comfy/comfortable-mexican-sofa/raw/master/doc/preview.png)

Help and Contact
----------------

GoogleGroups: http://groups.google.com/group/comfortable-mexican-sofa
Twitter: [@GroceryBagHead](http://twitter.com/#!/GroceryBagHead)

---

ComfortableMexicanSofa is released under the [MIT license](https://github.com/comfy/comfortable-mexican-sofa/raw/master/LICENSE) 

Copyright 2009-2013 Oleg Khabarov, [The Working Group Inc](http://www.twg.ca)


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/comfy/comfortable-mexican-sofa/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

