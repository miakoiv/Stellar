#encoding: utf-8

class ContentController < ApplicationController

  layout false

  # GET /content/feed
  def feed
    @id = params[:id]
    store = Store.find(params[:store])
    paginates_per = params[:items].to_i
    content_class = params[:contentClass].classify
    gateway_class = "ContentGateway::#{content_class}".constantize
    items, count = gateway_class.new(store).feed(params)
    @items = Kaminari.paginate_array(items, total_count: count).page(params[:page]).per(paginates_per)

    respond_to do |format|
      format.html
      format.js
    end
  rescue StandardError => e
    @error_message = e.message
    logger.warn @error_message
  end
end
