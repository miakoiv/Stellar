class AddLayoutToSections < ActiveRecord::Migration
  def change
    add_column :sections, :layout, :string, null: false, default: 'twelve', after: :outline
  end
end
