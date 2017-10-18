class AddSourceAndDestinationToOrderTypes < ActiveRecord::Migration
  def change
    add_reference :order_types, :source, null: false, index: true, after: :store_id
    add_reference :order_types, :destination, null: false, index: true, after: :source_id
  end
end
