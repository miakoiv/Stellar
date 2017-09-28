class RemoveAppearanceFromRoles < ActiveRecord::Migration
  def change
    remove_column :roles, :appearance, :string, null: false, default: 'default', after: :name
  end
end
