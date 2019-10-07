module ContentGateway
  class ArticleFeed < RssFeed
    private
      def build_content_item(item)
        ContentItem::Article.new(
          title: item.title,
          date: item.pubDate,
          categories: item.categories.map(&:content),
          content: item.content_encoded,
          link: item.link
        )
      end
    end
end
