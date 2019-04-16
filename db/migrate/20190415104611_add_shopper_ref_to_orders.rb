class AddShopperRefToOrders < ActiveRecord::Migration[5.2]
  def up
    add_reference :orders, :shopper, index: true, after: :user_id

    Order.incomplete.find_each(batch_size: 50) do |order|
      user = order.user
      if user.nil?
        order.destroy
      else
        group = user.group(order.store)
        if group.nil?
          order.update_columns(shopper_id: user.id)
        else
          order.destroy if order.order_items_count == 0
        end
      end
    end
  end

  def down
    remove_reference :orders, :shopper
  end
end
