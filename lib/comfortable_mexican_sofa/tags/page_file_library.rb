class ComfortableMexicanSofa::Tag::PageFileLibrary < ComfortableMexicanSofa::Tag::PageFile
  include ComfortableMexicanSofa::Tag

  # Signature of a tag:
  #   {{ cms:page_file_library:some_label:type:params }}
  # Simple tag can be:
  #   {{ cms:page_file_library:some_label }}
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page_file_library:(#{identifier}):?(.*?)\s*\}\}/
  end

  def content
    block.content
  end

  def file
    @file ||= Comfy::Cms::File.where(id: block.content).first
  end

end
