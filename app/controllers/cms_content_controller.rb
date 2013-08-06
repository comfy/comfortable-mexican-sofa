class CmsContentController < ApplicationController
  
  # Authentication module must have #authenticate method
  include ComfortableMexicanSofa.config.public_auth.to_s.constantize
  
  before_action :load_cms_site,
                :load_fixtures
  before_action :load_cms_page,
                :authenticate,
                :only => :render_html
  before_action :load_cms_layout,
                :only => [:render_css, :render_js]
  
  def render_html(status = 200)
    if @cms_layout = @cms_page.layout
      app_layout = (@cms_layout.app_layout.blank? || request.xhr?) ? false : @cms_layout.app_layout
      render :inline => @cms_page.content(@variation_identifier), :layout => app_layout, :status => status, :content_type => 'text/html'
    else
      render :text => I18n.t('cms.content.layout_not_found'), :status => 404
    end
  end

  def render_sitemap
    render
  end

  def render_css
    render :text => @cms_layout.css, :content_type => 'text/css'
  end

  def render_js
    render :text => @cms_layout.js, :content_type => 'text/javascript'
  end

protected

  def load_fixtures
    return unless ComfortableMexicanSofa.config.enable_fixtures
    ComfortableMexicanSofa::Fixture::Importer.new(@cms_site.identifier).import!
  end
  
  def load_cms_site
    @cms_site ||= if params[:site_id]
      Cms::Site.find_by_id(params[:site_id])
    else
      Cms::Site.find_site(request.host_with_port.downcase, request.fullpath)
    end
    
    if @cms_site
      if params[:cms_path].present?
        params[:cms_path].gsub!(/^#{@cms_site.path}/, '')
        params[:cms_path].to_s.gsub!(/^\//, '')
      end
      I18n.locale = @cms_site.locale
    else
      I18n.locale = I18n.default_locale
      raise ActionController::RoutingError.new('Site Not Found')
    end
  end
  
  def load_cms_page
    @variation_identifier ||= Cms::Variation.list.first
    # Allow an override within the params (used in the test suite)
    if params[:variation_identifier]
      @variation_identifier = params[:variation_identifier]
    end
    if ComfortableMexicanSofa.config.variations.present?
      @cms_page = Cms::Page.with_full_path_and_identifier("/#{params[:cms_path]}", @variation_identifier, @cms_site).first
      @cms_page_content = @cms_page.page_contents.for_variation(@variation_identifier).first
      raise ActiveRecord::RecordNotFound unless @cms_page
    else
      @cms_page = Cms::Page.with_full_path("/#{params[:cms_path]}", @cms_site).first
    end
    if @cms_page && @cms_page.target_page.present? && @cms_page.target_page.page_content.present?
      return redirect_to(@cms_page.target_page.page_content.url)
    end
    
  rescue ActiveRecord::RecordNotFound
    if @cms_page = Cms::Page.with_full_path_and_identifier("/404", @variation_identifier, @cms_site).first
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

end
