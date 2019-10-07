#
# ContentItem module contains classes for items loaded from feeds
# by classes in the ContentGateway module.
#
module ContentItem
  class Headline
    include ActiveModel::Model

    attr_accessor :title, :date, :categories, :link

    def to_partial_path
      'content/headline'
    end
  end
end
