module Reorderer
  extend ActiveSupport::Concern

  # POST /admin/orderable/reorder
  def reorder
    ActiveRecord::Base.transaction do
      reordered_items.each_with_index do |item, index|
        item.update_columns(priority: index)
      end
    end
    render nothing: true
  end

  private
    def reordered_items
      ids = params[:reorder]
      return [] if ids.nil?
      ids.map do |param|
        param =~ /(.+)_(\d+)$/ && $1.classify.constantize.find($2)
      end
    end
end
