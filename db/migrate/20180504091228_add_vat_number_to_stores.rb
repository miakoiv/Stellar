class AddVatNumberToStores < ActiveRecord::Migration
  def change
    add_column :stores, :vat_number, :string, after: :erp_number
  end
end
