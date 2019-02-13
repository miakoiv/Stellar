class KoalaController < ApplicationController

  layout false

  # GET /koala/feed
  def feed
    resource = GlobalID::Locator.locate(params[:gid])
    page = params[:page]
    items = params[:items]
    graph = Koala::Facebook::API.new(resource.facebook_token)
    feed = graph.get_connection(page, 'posts', {
      api_version: 'v3.0',
      limit: items,
      fields: %w{message full_picture link type created_time}
    })
    @posts = feed.map do |item|
      Koala::Post.new(
        message: item['message'],
        picture: item['full_picture'],
        link: item['link'],
        type: item['type'],
        created_at: item['created_time']
      )
    end
  rescue StandardError => e
    @error_message = e.message
  end
end
