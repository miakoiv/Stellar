class RemoveDeprecatedFieldsFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :customer_name, :string, after: :concluded_at
    remove_column :orders, :customer_phone, :string, after: :customer_email
    remove_column :orders, :company_name, :string, after: :customer_phone
    remove_column :orders, :contact_person, :string, after: :company_name
    remove_column :orders, :contact_phone, :string, after: :contact_email
  end
end
