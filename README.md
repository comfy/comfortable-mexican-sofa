# ComfortableMexicanSofa
[![Gem Version](https://img.shields.io/gem/v/comfortable_mexican_sofa.svg?style=flat)](http://rubygems.org/gems/comfortable_mexican_sofa) [![Gem Downloads](https://img.shields.io/gem/dt/comfortable_mexican_sofa.svg?style=flat)](http://rubygems.org/gems/comfortable_mexican_sofa) [![Build Status](https://img.shields.io/travis/comfy/comfortable-mexican-sofa.svg?style=flat)](https://travis-ci.org/comfy/comfortable-mexican-sofa) [![Dependency Status](https://img.shields.io/gemnasium/comfy/comfortable-mexican-sofa.svg?style=flat)](https://gemnasium.com/comfy/comfortable-mexican-sofa) [![Code Climate](https://img.shields.io/codeclimate/github/comfy/comfortable-mexican-sofa.svg?style=flat)](https://codeclimate.com/github/comfy/comfortable-mexican-sofa) [![Coverage Status](https://img.shields.io/coveralls/comfy/comfortable-mexican-sofa.svg?style=flat)](https://coveralls.io/r/comfy/comfortable-mexican-sofa?branch=master)

ComfortableMexicanSofa is a powerful Rails 4/5 CMS Engine

## Features

* Simple integration with Rails 4 apps
* Build your application in Rails, not in CMS
* Powerful page templating capability using [Tags](https://github.com/comfy/comfortable-mexican-sofa/wiki/Tags)
* [Multiple Sites](https://github.com/comfy/comfortable-mexican-sofa/wiki/Sites) from a single installation
* Multi-Language Support (i18n) (cs, da, de, en, es, fr, it, ja, nb, nl, pl, pt-BR, ru, sv, tr, uk, zh-CN, zh-TW)
* [Fixtures](https://github.com/comfy/comfortable-mexican-sofa/wiki/Working-with-CMS-fixtures) for initial content population
* [Revision History](https://github.com/comfy/comfortable-mexican-sofa/wiki/Revisions)
* [Great extendable admin interface](https://github.com/comfy/comfortable-mexican-sofa/wiki/Reusing-sofa%27s-admin-area) built with [Bootstrap](http://getbootstrap.com), [CodeMirror](http://codemirror.net/) and [Redactor](http://imperavi.com/redactor)

## Installation

Add gem definition to your Gemfile:

```ruby
gem 'comfortable_mexican_sofa', '~> 1.12.0'
```

Then from the Rails project's root run:

    bundle install
    rails generate comfy:cms
    rake db:migrate

Now take a look inside your `config/routes.rb` file. You'll see where routes attach for the admin area and content serving. Make sure that content serving route appears as a very last item.

```ruby
comfy_route :cms_admin, :path => '/admin'
comfy_route :cms, :path => '/', :sitemap => false
```

When upgrading from the older version please take a look at [Upgrading ComfortableMexicanSofa](https://github.com/comfy/comfortable-mexican-sofa/wiki/Upgrading-ComfortableMexicanSofa)

### Installation for Rails 3

For Rails 3 apps feel free to use [1.8 release](https://github.com/comfy/comfortable-mexican-sofa/tree/1.8)

```ruby
gem 'comfortable_mexican_sofa', '~> 1.8.0'
```

## Quick Start Guide

After finishing installation you should be able to navigate to http://yoursite/admin

Default username and password is 'username' and 'password'. You probably want to change it right away. Admin credentials (among other things) can be found and changed in the cms initializer: [/config/initializers/comfortable\_mexican\_sofa.rb](https://github.com/comfy/comfortable-mexican-sofa/blob/master/config/initializers/comfortable_mexican_sofa.rb)

Before creating pages and populating them with content we need to create a Site. Site defines a hostname, content path and its language.

After creating a Site, you need to make a Layout. Layout is the template of your pages; it defines some reusable content (like header and footer, for example) and places where the content goes. A very simple layout can look like this:

```html
<html>
  <body>
    <h1>{{ cms:page:header:string }}</h1>
    {{ cms:page:content:rich_text }}
  </body>
</html>
```

[See Wiki entry on available Tags you can use](https://github.com/comfy/comfortable-mexican-sofa/wiki/Tags)

Once you have a layout, you may start creating pages and populating content. It's that easy.

For more information please refer to [Wiki](https://github.com/comfy/comfortable-mexican-sofa/wiki).

![Sofa's Page Edit View](https://github.com/comfy/comfortable-mexican-sofa/raw/master/doc/preview.png)

#### Dependencies

* Install [ImageMagick](http://www.imagemagick.org/) for [paperclip](https://github.com/thoughtbot/paperclip)'s image processing
* Make sure that Gemfile has either [kaminari](https://github.com/amatsuda/kaminari) or [will_paginate](https://github.com/mislav/will_paginate)

#### Help and Contact

GoogleGroups: http://groups.google.com/group/comfortable-mexican-sofa

Twitter: [@GroceryBagHead](http://twitter.com/#!/GroceryBagHead)

#### Acknowledgements

* Big thanks to Roman Almeida ([@nasmorn](https://github.com/nasmorn)) for contributing OEM License for [Redactor Text Editor](http://imperavi.com/redactor)

---

ComfortableMexicanSofa is released under the [MIT license](https://github.com/comfy/comfortable-mexican-sofa/raw/master/LICENSE)

Copyright 2009-2017 Oleg Khabarov
