#
# ContentItem module contains classes for items loaded from feeds
# by classes in the ContentGateway module.
#
module ContentItem
  class Card
    include ActiveModel::Model

    attr_accessor :title, :subtitle, :image, :description, :link, :price, :type, :size

    def to_partial_path
      'content/card'
    end
  end
end
