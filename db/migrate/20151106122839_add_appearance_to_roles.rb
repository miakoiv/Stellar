class AddAppearanceToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :appearance, :string, null: false, default: 'default', after: :name
  end
end
