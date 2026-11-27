# frozen_string_literal: true

# Exactly the same as Files, but form input allows only one attachment
class ComfortableMexicanSofa::Content::Tag::FileTag < ComfortableMexicanSofa::Content::Tag::FilesTag
  MULTIPLE = false
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :file, ComfortableMexicanSofa::Content::Tag::FileTag
)
