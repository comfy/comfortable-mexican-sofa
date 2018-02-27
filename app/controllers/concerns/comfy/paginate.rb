# frozen_string_literal: true

module Comfy::Paginate

  # Wrapper to deal with WillPaginate vs Kaminari nonsense
  def comfy_paginate(scope, per_page: 50)
    if defined?(WillPaginate)
      scope.paginate(page: params[:page], per_page: per_page)
    elsif defined?(Kaminari)
      scope.page(params[:page]).per(per_page)
    else
      scope
    end
  end

end
