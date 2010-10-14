# Authentication module must have #authenticate method
include ComfortableMexicanSofa.config.authentication.to_s.constantize

class CmsAdmin::BaseController < ApplicationController
  
  before_filter :authenticate
  
  layout 'cms_admin'
  
end
