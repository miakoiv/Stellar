class ContentController < ApplicationController

  layout false

  # GET /content/feed
  def feed
    p = content_params
    @id = p[:id]
    store = Store.find(p[:store])
    paginates_per = p[:items].to_i
    content_class = p[:contentClass].classify
    gateway_class = "ContentGateway::#{content_class}".constantize
    items, count = gateway_class.new(store).feed(p)
    @items = Kaminari.paginate_array(items, total_count: count).page(p[:page]).per(paginates_per)

    respond_to do |format|
      format.html
      format.js
    end
  rescue StandardError => e
    @error_message = e.message
    logger.warn @error_message
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def content_params
      params.permit(:id, :store, :items, :contentClass, :contentType, :page)
    end
end
