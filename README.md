# ComfortableMexicanSofa (Rails 3 CMS Engine) 
[![Build Status](https://secure.travis-ci.org/comfy/comfortable-mexican-sofa.png)](http://travis-ci.org/comfy/comfortable-mexican-sofa) [![Dependency Status](https://gemnasium.com/comfy/comfortable-mexican-sofa.png)](https://gemnasium.com/comfy/comfortable-mexican-sofa)

ComfortableMexicanSofa is a powerful CMS Engine for your Rails 3 applications.

Features
--------
* Simple integration with Rails 3 apps (with or without assets pipeline)
* Build your application in Rails, not in CMS
* Powerful page templating capability using [Tags](https://github.com/comfy/comfortable-mexican-sofa/wiki/Tags)
* [Multiple Sites](https://github.com/comfy/comfortable-mexican-sofa/wiki/Sites) from a single installation
* Multilingual
* [Fixtures](https://github.com/comfy/comfortable-mexican-sofa/wiki/Working-with-CMS-fixtures) for initial content population
* [Revision History](https://github.com/comfy/comfortable-mexican-sofa/wiki/Revisions)
* [Great reusable admin interface](https://github.com/comfy/comfortable-mexican-sofa/wiki/Reusing-sofa%27s-admin-area)
* Almost no 3rd party library dependencies

Installation
------------
Add gem definition to your Gemfile:
    
    gem 'comfortable_mexican_sofa'
    
Then from the Rails project's root run:
    
    bundle install
    rails generate comfy:cms
    rake db:migrate
    
When upgrading from the older version please take a look at [Upgrading ComfortableMexicanSofa](https://github.com/comfy/comfortable-mexican-sofa/wiki/Upgrading-ComfortableMexicanSofa)
    
Quick Start Guide
-----------------
After finishing installation you should be able to navigate to http://yoursite/cms-admin

Default username and password is 'username' and 'password'. You probably want to change it right away. Admin credentials (among other things) can be found and changed in the cms initializer: [/config/initializers/comfortable\_mexican\_sofa.rb](https://github.com/comfy/comfortable-mexican-sofa/blob/master/config/initializers/comfortable_mexican_sofa.rb)

Before creating pages and populating them with content we need to create a Site. Site defines a hostname, content path and it's language.

After creating a Site, you need to make a Layout. Layout is the template of your pages; it defines some reusable content (like header and footer, for example) and places where the content goes. A very simple layout can look like this:
    
    <html>
      <body>
        <h1>{{ cms:page:header:string }}</h1>
        {{ cms:page:content:text }}
      </body>
    </html>

Once you have a layout, you may start creating pages and populating content. It's that easy.

For more information please [see Wiki pages](https://github.com/comfy/comfortable-mexican-sofa/wiki).

![Sofa's Page Edit View](https://github.com/comfy/comfortable-mexican-sofa/raw/master/doc/preview.png)

---

ComfortableMexicanSofa is released under the [MIT license](https://github.com/comfy/comfortable-mexican-sofa/raw/master/LICENSE) 

Copyright 2009-2011 Oleg Khabarov, [The Working Group Inc](http://www.twg.ca)