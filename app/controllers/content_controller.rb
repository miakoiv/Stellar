#encoding: utf-8

class ContentController < ApplicationController

  layout false

  # GET /content/feed
  def feed
    store = Store.find(params.delete(:store))
    content_class = params.delete(:contentClass).classify
    gateway_class = "ContentGateway::#{content_class}".constantize
    @items = gateway_class.new(store).feed(params)
  rescue StandardError => e
    @error_message = e.message
    logger.warn @error_message
  end
end
