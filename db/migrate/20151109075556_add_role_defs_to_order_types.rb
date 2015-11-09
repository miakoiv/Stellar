class AddRoleDefsToOrderTypes < ActiveRecord::Migration
  def change
    add_reference :order_types, :source_role, index: true, after: :name
    add_reference :order_types, :destination_role, index: true, after: :source_role_id
  end
end
