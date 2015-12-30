class AddContactPhoneToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :contact_phone, :string, after: :contact_person
  end
end
