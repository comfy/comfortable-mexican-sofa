# frozen_string_literal: true

module Comfy::Paginate
  def comfy_paginate(scope, per_page: 50)
    if defined?(Kaminari)
      scope.page(params[:page]).per(per_page)
    else
      scope
    end
  end
end
