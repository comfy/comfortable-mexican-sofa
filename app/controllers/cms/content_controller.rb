class Cms::ContentController < Cms::BaseController
  
  # Authentication module must have #authenticate method
  include ComfortableMexicanSofa.config.public_auth.to_s.constantize
  
  
  before_action :load_fixtures
  before_action :load_cms_page,
                :authenticate,
                :only => :render_html
  before_action :load_cms_layout,
                :only => [:render_css, :render_js]
  
  def render_html(status = 200)
    if @cms_layout = @cms_page.layout
      app_layout = (@cms_layout.app_layout.blank? || request.xhr?) ? false : @cms_layout.app_layout

      content = @cms_page.content
      content << injected_admin_javascript if current_admin_cms_user

      render :inline => content, :layout => app_layout, :status => status, :content_type => 'text/html'
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

protected

  def load_fixtures
    return unless ComfortableMexicanSofa.config.enable_fixtures
    ComfortableMexicanSofa::Fixture::Importer.new(@cms_site.identifier).import!
  end
  
  def load_cms_page
    @cms_page = @cms_site.pages.published.find_by_full_path!("/#{params[:cms_path]}")
    return redirect_to(@cms_page.target_page.url) if @cms_page.target_page
    
  rescue ActiveRecord::RecordNotFound
    if @cms_page = @cms_site.pages.published.find_by_full_path('/404')
      render_html(404)
    else
      raise ActionController::RoutingError.new('Page Not Found')
    end
  end

  def load_cms_layout
    @cms_layout = @cms_site.layouts.find_by_identifier!(params[:identifier])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => 404
  end

  def injected_admin_javascript
    "\n" + ActionController::Base.helpers.javascript_include_tag("comfortable_mexican_sofa/admin/edit_content") +
    "\n" + ActionController::Base.helpers.stylesheet_link_tag("comfortable_mexican_sofa/admin/wysihtml5_overrides")
  end
end
