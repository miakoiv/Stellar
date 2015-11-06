class RemoveStoreContactPersonNameStoreContactPersonEmailFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :store_contact_person_name, :string
    remove_column :orders, :store_contact_person_email, :string
  end
end
