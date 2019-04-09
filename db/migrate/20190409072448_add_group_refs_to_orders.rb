class AddGroupRefsToOrders < ActiveRecord::Migration[5.2]
  def up
    add_reference :orders, :billing_group, type: :integer, null: false, index: true, after: :user_id
    add_reference :orders, :shipping_group, type: :integer, null: false, index: true, after: :billing_group_id

    Order.unscoped.find_each(batch_size: 50) do |order|
      store = order.store
      customer = User.find_by(id: order.customer_id)
      group = customer.present? ? customer.effective_group(store) : store.default_group
      order.update_columns(
        billing_group_id: group.id,
        shipping_group_id: group.id
      )
    end
  end

  def down
    remove_reference :orders, :billing_group
    remove_reference :orders, :shipping_group
  end
end
