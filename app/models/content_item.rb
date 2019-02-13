#
# ContentItem is a convenience model for items loaded from feeds
# by classes in the ContentGateway module.
#
class ContentItem

  include ActiveModel::Model

  attr_accessor :title, :subtitle, :image, :description, :link, :price, :type, :size

  def to_partial_path
    'content/item'
  end
end
