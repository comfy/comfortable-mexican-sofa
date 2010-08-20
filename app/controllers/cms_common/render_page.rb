module CmsCommon::RenderPage
  
  def render_page(options = { })  
    if @cms_page.blank?
      if (@cms_page = CmsPage.published.find_by_full_path('404'))
        render :inline => @cms_page.content, :layout => (@cms_page.cms_layout.app_layout || false), :status => 404
      else
        render :text => '404 Page Not Found', :status => 404
      end
    else
      if @cms_page.redirect_to_page
        redirect_to @cms_page.redirect_to_page.full_path
      else
        layout = (@cms_page.cms_layout.app_layout || false)
        render :inline => @cms_page.content, :layout => layout
      end
    end
  end
  
end
