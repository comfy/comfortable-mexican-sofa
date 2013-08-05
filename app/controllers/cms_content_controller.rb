class CmsContentController < ApplicationController
  
  # Authentication module must have #authenticate method
  include ComfortableMexicanSofa.config.public_auth.to_s.constantize
  include ComfyFilters
  
  def render_html(status = 200)
    if @cms_layout = @cms_page.layout
      app_layout = (@cms_layout.app_layout.blank? || request.xhr?) ? false : @cms_layout.app_layout
      render :inline => @cms_page.content, :layout => app_layout, :status => status, :content_type => 'text/html'
    else
      render :text => I18n.t('cms.content.layout_not_found'), :status => 404
    end
  end

  def render_sitemap
    render
  end

  def render_css
    render :text => @cms_layout.css, :content_type => 'text/css'

  rescue Exception => e
    render text: "Error constructing your CSS. Make sure your use of Comfy tags is OK and none of them expect a CMS page instead of a CMS layout as context. Error message is: #{e.message}"
  end

  def render_js
    render :text => @cms_layout.js, :content_type => 'text/javascript'
  end


end
