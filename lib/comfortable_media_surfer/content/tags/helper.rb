# frozen_string_literal: true

# Tag for injecting view helpers. Example tag:
#   {{cms:helper method_name, param_a, param_b, foo: bar}}
# This expands into something like this:
#   <%= method_name("param_a", "param_b", "foo" => "bar") %>
# Whitelist is can be used to control what helpers are available.
# By default there's a blacklist of methods that should not be called.
#
class ComfortableMediaSurfer::Content::Tags::Helper < ComfortableMediaSurfer::Content::Tag
  BLACKLIST = %w[eval class_eval instance_eval render].freeze

  attr_reader :method_name

  def initialize(context:, params: [], source: nil)
    super
    @method_name = params.shift

    return if @method_name.present?

    raise Error, 'Missing method name for helper tag'
  end

  # we output erb into rest of the content
  def allow_erb?
    true
  end

  def content
    helper_params = params.map do |p|
      case p
      when Hash
        format('%<arg>s', arg: p)
      else
        format('%<arg>p', arg: p)
      end
    end.join(',')
    "<%= #{method_name}(#{helper_params}) %>"
  end

  def render
    whitelist = ComfortableMediaSurfer.config.allowed_helpers
    if whitelist.is_a?(Array)
      content if whitelist.map!(&:to_s).member?(method_name)
    else
      content unless BLACKLIST.member?(method_name)
    end
  end
end

ComfortableMediaSurfer::Content::Renderer.register_tag(
  :helper, ComfortableMediaSurfer::Content::Tags::Helper
)
