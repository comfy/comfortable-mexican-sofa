class CmsAdmin::AssetsController < CmsAdmin::BaseController
  before_filter :load_cms_asset,
    :only => :destroy
  
  def index
  end
  
  def create
    @cms_asset = CmsAsset.create!(:uploaded_file => params[:file])
    render(:partial => 'cms_admin/assets/asset', :object => @cms_asset)
  end
  
  def destroy
    @cms_asset.destroy
  end

protected
  def load_cms_asset
    @cms_asset = CmsAsset.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end
end
