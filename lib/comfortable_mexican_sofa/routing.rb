# frozen_string_literal: true

require_relative "routes/cms_admin"
require_relative "routes/cms"

class ActionDispatch::Routing::Mapper

  def comfy_route(identifier)
    send("comfy_route_#{identifier}")
  end

end
