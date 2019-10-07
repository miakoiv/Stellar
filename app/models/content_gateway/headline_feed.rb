module ContentGateway
  class HeadlineFeed < RssFeed
    private
      def build_content_item(item)
        ContentItem::Headline.new(
          title: item.title,
          date: item.pubDate,
          link: item.link
        )
      end
    end
end
