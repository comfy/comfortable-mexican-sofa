class Admin::FoosController < Admin::Cms::BaseController

  before_action :build_foo,  :only => [:new, :create]
  before_action :load_foo,   :only => [:show, :edit, :update, :destroy]

  def index
    @foos = Foo.page(params[:page])
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
    @foo.save!
    flash[:success] = 'Foo created'
    redirect_to :action => :show, :id => @foo
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to create Foo'
    render :action => :new
  end

  def update
    @foo.update_attributes!(foo_params)
    flash[:success] = 'Foo updated'
    redirect_to :action => :show, :id => @foo
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to update Foo'
    render :action => :edit
  end

  def destroy
    @foo.destroy
    flash[:success] = 'Foo deleted'
    redirect_to :action => :index
  end

protected

  def build_foo
    @foo = Foo.new(foo_params)
  end

  def load_foo
    @foo = Foo.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Foo not found'
    redirect_to :action => :index
  end

  def foo_params
    params.fetch(:foo, {}).permit(:bar)
  end
end