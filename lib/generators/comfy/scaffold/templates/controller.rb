class Admin::<%= class_name.pluralize %>Controller < Admin::Cms::BaseController

  before_action :build_<%= file_name %>,  :only => [:new, :create]
  before_action :load_<%= file_name %>,   :only => [:show, :edit, :update, :destroy]

  def index
    @<%= file_name.pluralize %> = <%= class_name %>.page(params[:page])
  end

  def show
    render
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @<%= file_name %>.save!
    flash[:success] = '<%= class_name.titleize %> created'
    redirect_to :action => :show, :id => @<%= file_name %>
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to create <%= class_name.titleize %>'
    render :action => :new
  end

  def update
    @<%= file_name %>.update_attributes!(<%= file_name %>_params)
    flash[:success] = '<%= class_name.titleize %> updated'
    redirect_to :action => :show, :id => @<%= file_name %>
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to update <%= class_name.titleize %>'
    render :action => :edit
  end

  def destroy
    @<%= file_name %>.destroy
    flash[:success] = '<%= class_name.titleize %> deleted'
    redirect_to :action => :index
  end

protected

  def build_<%= file_name %>
    @<%= file_name %> = <%= class_name %>.new(<%= file_name %>_params)
  end

  def load_<%= file_name %>
    @<%= file_name %> = <%= class_name %>.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = '<%= class_name.titleize %> not found'
    redirect_to :action => :index
  end

  def <%= file_name %>_params
    params.fetch(:<%= file_name %>, {}).permit(<%= model_attrs.collect{|attr| ":#{attr.name}"}.join(', ') %>)
  end
end