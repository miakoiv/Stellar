#
# ContentGateway::RssFeed implements a content gateway interface
# to any RSS-formatted feed. To use the gateway, initialize an object
# from one of its subclasses, ArticleFeed or HeadlineFeed.
#
# Calling the feed method will load the feed from the URL
# given in params, and return a set of ContentItem objects.
#
require 'rss'

module ContentGateway
  class RssFeed
    def initialize(store)
      @store = store
    end

    # Loads the feed and returns a tuple of [items, count]
    def feed(params = {})
      url = params['url'].presence or raise 'No URL specified'
      open(url) do |rss|
        feed = ::RSS::Parser.parse(rss)
        items = feed.items.map { |item| build_content_item(item) }
        return [items, items.count]
      end
    end

    private
      # Implementations can be found in subclasses of RssFeed.
      def build_content_item
      end
  end
end
