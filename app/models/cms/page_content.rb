# encoding: utf-8

class Cms::PageContent < ActiveRecord::Base

  self.table_name = 'cms_page_contents'

  belongs_to :page

end
