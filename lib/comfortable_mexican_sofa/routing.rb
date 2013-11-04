require_relative 'routes/cms_admin'
require_relative 'routes/cms'

class ActionDispatch::Routing::Mapper
  def comfy_route(identifier, options = {})
    send("comfy_route_#{identifier}", options)
  end
end