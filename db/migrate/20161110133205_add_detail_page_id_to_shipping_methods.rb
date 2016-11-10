class AddDetailPageIdToShippingMethods < ActiveRecord::Migration
  def change
    add_reference :shipping_methods, :detail_page, after: :description
  end
end
