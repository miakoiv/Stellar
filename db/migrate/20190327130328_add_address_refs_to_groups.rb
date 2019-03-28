class AddAddressRefsToGroups < ActiveRecord::Migration[5.2]
  def change
    add_reference :groups, :billing_address, type: :integer, after: :premium_teaser
    add_reference :groups, :shipping_address, type: :integer, after: :billing_address_id
  end
end
