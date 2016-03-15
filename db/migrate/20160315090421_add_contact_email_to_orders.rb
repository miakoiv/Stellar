class AddContactEmailToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :contact_email, :string, after: :contact_person
  end
end
