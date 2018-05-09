#encoding: utf-8

class KoalaController < ApplicationController

  layout false

  # GET /koala/feed
  def feed
    page = params[:page]
    items = params[:items]
    graph = Koala::Facebook::API.new(current_store.facebook_access_token)
    feed = graph.get_connection(page, 'posts', {
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
