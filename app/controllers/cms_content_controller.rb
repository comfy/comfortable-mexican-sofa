class CmsContentController < ApplicationController
  
  def show
    render :inline => '<h1>Hello World!</h1>'
  end
  
end
