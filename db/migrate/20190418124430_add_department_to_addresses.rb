class AddDepartmentToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :department, :string, null: false, default: '', after: :company
  end
end
