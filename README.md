[![Rails CI](https://github.com/shakacode/comfortable-media-surfer/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/shakacode/comfortable-media-surfer/actions/workflows/rubyonrails.yml)
[![Coverage Status](https://coveralls.io/repos/github/shakacode/comfortable-media-surfer/badge.svg?branch=master)](https://coveralls.io/github/shakacode/comfortable-media-surfer?branch=master)
[![Gem Version](https://img.shields.io/gem/v/comfortable_media_surfer.svg?style=flat)](http://rubygems.org/gems/comfortable_media_surfer)
[![Gem Downloads](https://img.shields.io/gem/dt/comfortable_media_surfer.svg?style=flat)](http://rubygems.org/gems/comfortable_media_surfer)
[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/shakacode/comfortable-media-surfer?label=last%20release&color=seagreen)](https://github.com/shakacode/comfortable-media-surfer/releases)

# ComfortableMediaSurfer

ComfortableMediaSurfer is a powerful Ruby 7.0+ CMS (Content Management System) Engine, picking up where [ComfortableMexicanSofa](https://github.com/comfy/comfortable-mexican-sofa) left off.

## Features

- Simple drop-in integration with Rails 7.0+ apps with minimal configuration
* The CMS keeps clear from the rest of your application
* Powerful page templating capability using [Content Tags](https://github.com/shakacode/comfortable-media-surfer/wiki/Docs:-Content-Tags)
* [Multiple Sites](https://github.com/shakacode/comfortable-media-surfer/wiki/Docs:-Sites) from a single installation
* Multi-Language Support (i18n) (ca, cs, da, de, en, es, fi, fr, gr, hr, it, ja, nb, nl, pl, pt-BR, ru, sv, tr, uk, zh-CN, zh-TW) and page localization.
* [CMS Seeds](https://github.com/shakacode/comfortable-media-surfer/wiki/Docs:-CMS-Seeds) for initial content population
* [Revision History](https://github.com/shakacode/comfortable-media-surfer/wiki/Docs:-Revisions) to revert changes
* [Extendable Admin Area](https://github.com/shakacode/comfortable-media-surfer/wiki/HowTo:-Reusing-Admin-Area) built with [Bootstrap 4](http://getbootstrap.com) (responsive design). Using [CodeMirror](http://codemirror.net) for HTML and Markdown highlighing and [Redactor](http://imperavi.com/redactor) as the WYSIWYG editor.

## Dependencies

- File attachments are handled by [ActiveStorage](https://github.com/rails/rails/tree/master/activestorage). Make sure that you can run appropriate migrations by running: `rails active_storage:install`
- Image resizing is done with with [ImageMagick](http://www.imagemagick.org/script/download.php), so make sure it's installed.
- Pagination is handled by [kaminari](https://github.com/amatsuda/kaminari).

## Compatibility

On Ruby 3.x, Rails 7.x +

## Installation

Add gem definition to your Gemfile:

```ruby
gem "comfortable_media_surfer", "~> 3.1.0"
```

Then from the Rails project's root run:

```
    bundle install
    rails generate comfy:cms
    rake db:migrate
```

Now take a look inside your `config/routes.rb` file. You'll see where routes attach for the admin area and content serving. Make sure that content serving route appears as a very last item or it will make all other routes to be inaccessible.

```ruby
comfy_route :cms_admin, path: "/admin"
comfy_route :cms, path: "/"
```

## Quick Start Guide

After finishing installation you should be able to navigate to http://localhost:3000/admin

Default username and password is 'user' and 'pass'. You probably want to change it right away. Admin credentials (among other things) can be found and changed in the cms initializer: [/config/initializers/comfortable_media_surfer.rb](https://github.com/shakacode/comfortable-media-surfer/blob/master/config/initializers/comfortable_media_surfer.rb)

Before creating pages and populating them with content we need to create a Site. Site defines a hostname, content path and its language.

After creating a Site, you need to make a Layout. Layout is the template of your pages; it defines some reusable content (like header and footer, for example) and places where the content goes. A very simple layout can look like this:

```html
<html>
  <body>
    <h1>{{ cms:text title }}</h1>
    {{ cms:wysiwyg content }}
  </body>
</html>
```

Once you have a layout, you may start creating pages and populating content. It's that easy.

## Documentation

For more information on how to use this CMS please refer to the [Wiki](https://github.com/shakacode/comfortable-media-surfer/wiki). Section that might be of interest is the entry
on [Content Tags](https://github.com/shakacode/comfortable-media-surfer/wiki/Docs:-Content-Tags).

## Add-ons

If you want to add a Blog functionality to your app take a look at
[ComfyBlog](https://github.com/comfy/comfy-blog).

![Admin Area Preview](doc/preview.jpg)

#### Old Versions of ComfortableMexicanSofa

[CHANGELOG](//github.com/comfy/comfortable-mexican-sofa/releases) is documented in ComfortableMexicanSofa Github releases.

#### Contributing

ComfortableMediaSurfer can run like any Rails application in development. It's as easy to work on as any other Rails app. For more detail see [CONTRIBUTING](CONTRIBUTING.md)

#### Testing

- `bin/rails db:migrate RAILS_ENV=test`
- `rake db:test:prepare`
- `rake test`

#### Acknowledgements

- to [Oleg Khabarov](https://github.com/GBH), the creator of [ComfortableMexicanSofa](https://github.com/comfy/comfortable-mexican-sofa)
- to [Roman Almeida](https://github.com/nasmorn) for contributing OEM License for [Redactor Text Editor](http://imperavi.com/redactor)

---

Copyright 2010-2019 Oleg Khabarov, 2024 ShakaCode LLC
Released under the [MIT license](LICENSE)
