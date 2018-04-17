#encoding: utf-8

class KoalaController < ApplicationController

  layout false

  # GET /koala/feed
  def feed
    page = params[:page]
    items = params[:items]
    graph = Koala::Facebook::API.new(current_store.facebook_access_token)
    @feed = graph.get_connection(page, 'posts', {
      limit: items,
      fields: %w{message full_picture link type created_time}
    })
  end
end
