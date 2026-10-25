# frozen_string_literal: true

# Tag for injecting view helpers. Example tag:
#   {{cms:helper method_name, param_a, param_b, foo: bar}}
# This expands into something like this:
#   <%= method_name("param_a", "param_b", "foo" => "bar") %>
# Whitelist is can be used to control what helpers are available.
# By default there's a blacklist of methods that should not be called.
#
class ComfortableMexicanSofa::Content::Tag::HelperTag < ComfortableMexicanSofa::Content::Tag
  attr_reader :method_name

  def initialize(context: nil, params: [], source: nil)
    super

    @method_name = @params.shift

    return if @method_name.present?

    raise Error, "Missing method name for helper tag: #{source}"
  end

  def content
    whitelist = Array.wrap(ComfortableMexicanSofa.config.allowed_helpers)
    return "" unless whitelist.map(&:to_s).member?(@method_name)

    helper_params = [
      *@params.map { |p| format("%<arg>p", arg: p) },
      *(format("%<arg>s", arg: @options) if @options.present?)
    ].join(",")

    "<%= #{method_name}(#{helper_params}) %>"
  end

  # ensuring that render does not escape erb tags
  def allow_erb?
    true
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :helper, ComfortableMexicanSofa::Content::Tag::HelperTag
)
