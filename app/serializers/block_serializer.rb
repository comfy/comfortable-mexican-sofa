require 'active_model_serializers'

class BlockSerializer < ActiveModel::Serializer
  attributes :identifier, :content, :created_at, :updated_at

  private

  def content
    scope == 'preview' ? object.content : object.last_published_content
  end
end
