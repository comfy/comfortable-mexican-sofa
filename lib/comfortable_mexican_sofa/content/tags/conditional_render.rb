# Renders image tag from http://picsum.photos
# Example: {{cms:lorem_picsum 400, 300}}
class ComfortableMexicanSofa::Content::Tag::ConditionalRender < ComfortableMexicanSofa::Content::Tag

    attr_reader :condition, :if_identifier, :else_identifier
  
    def initialize(context:, params: [], source: "")
      super
      @condition = params[0]
      @if_identifier  = params[1]
      @else_identifier = params[2]
  
      unless @if_identifier.present?
        raise Error, "Need at least one dimension of the image"
      end
    end
  
    def content
      if condition
        snippet(if_identifier).content
      elsif else_identifier.present?
        snippet(else_identifier).content
      end
    end

    # Grabbing or initializing Comfy::Cms::Snippet object
    def snippet(identifier)
      context.site.snippets.detect { |s| s.identifier == identifier } ||
        context.site.snippets.build(identifier: identifier)
    end
  end
  
  ComfortableMexicanSofa::Content::Renderer.register_tag(
    :conditional_render, ConditionalRender
  )