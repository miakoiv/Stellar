#
# ContentItem module contains classes for items loaded from feeds
# by classes in the ContentGateway module.
#
module ContentItem
  class Article
    include ActiveModel::Model

    attr_accessor :title, :date, :categories, :content, :link

    def to_partial_path
      'content/article'
    end
  end
end
