# frozen_string_literal: true

# Tag for injecting HTML5 audio player. Example tag:
#   {{ cms:audio "path/to/audio", style: "height: 22px; width: 80%" }}
# This expands into:
#   <audio controls src="path/to/audio"></audio>
# To customize your player style, add a 'audioplayer' class to your CSS, e.g
# .audioplayer {
#   border-radius: 6px;
#   height: 22px;
#   width: 60%;
#   margin: 2px 0 2px 8px;
#   padding: 0;
# }
# and/or pass in style overrides with the 'style' parameter, as above

class ComfortableMediaSurfer::Content::Tags::Audio < ComfortableMediaSurfer::Content::Tag
  attr_reader :path, :style, :locals

  def initialize(context:, params: [], source: nil)
    super
    @locals = params.extract_options!
    @path   = params[0]
    @style = ''
    @style = "<style>.audioplayer {#{@locals['style']}}</style>" if @locals['style']

    return if @path.present?

    raise Error, 'Missing path for audio tag'
  end

  def content
    format("#{@style}<audio controls class=\"audioplayer\" src=#{@path}></audio>")
  end
end

ComfortableMediaSurfer::Content::Renderer.register_tag(
  :audio, ComfortableMediaSurfer::Content::Tags::Audio
)
