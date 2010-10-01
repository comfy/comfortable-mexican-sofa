class CmsContentController < ApplicationController
  
  before_filter :load_cms_page,   :only => :render_html
  before_filter :load_cms_layout, :only => [:render_css, :render_js]
    
  def render_html
    # TODO
    render :inline => @cms_page.content
  end
  
  def render_css
    render :text => @cms_layout.merged_css, :content_type => 'text/css'
  end
  
  def render_js
    render :text => @cms_layout.merged_js, :content_type => 'text/javascript'
  end

protected
  
  def load_cms_page
    @cms_page = CmsPage.find_by_full_path!("/#{params[:cms_path]}")
  rescue ActiveRecord::RecordNotFound
    render :text => 'Page not found', :status => 404
  end
  
  def load_cms_layout
    @cms_layout = CmsLayout.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => 404
  end
  
end
