module Reorderer
  extend ActiveSupport::Concern

  # POST /admin/orderable/reorder
  def reorder
    reordered_items.each_with_index do |item, index|
      item.update(priority: index)
    end
    render nothing: true
  end

  private
    def reordered_items
      params[:reorder].map do |param|
        param =~ /(.+)_(\d+)$/ && $1.classify.constantize.find($2)
      end
    end
end
