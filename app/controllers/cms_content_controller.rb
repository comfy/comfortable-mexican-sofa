class CmsContentController < ApplicationController
  before_filter :load_cms_page
    
  def render_page
    # TODO
    render :text => 'found'
  end
  
  def render_css
    send_data @cms_page.cms_layout.merged_css,
      :filename => 'styles.css',
      :type => 'text/css'
  end
  
  def render_js
    send_data @cms_page.cms_layout.merged_js,
      :filename => 'jscript.js',
      :type => 'text/javascript'
  end

protected
  
  def load_cms_page
    @cms_page = CmsPage.find_by_full_path!("/#{params[:cms_path]}")
  rescue ActiveRecord::RecordNotFound
    render :text => 'Page not found', :status => 404
  end
  
end
