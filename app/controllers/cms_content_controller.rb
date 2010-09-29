class CmsContentController < ApplicationController
  before_filter :load_cms_layout,
    :only => [:render_css, :render_js]
    
  def render_page
    # TODO
  end
  
  def render_css
    send_data @cms_layout.css, :filename => 'styles.css', :type => 'text/css'
  end
  
  def render_js
    send_data @cms_layout.js, :filename => 'jscript.js', :type => 'text/javascript'
  end

protected
  
  def load_cms_layout
    @cms_layout = CmsLayout.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end
  
end
