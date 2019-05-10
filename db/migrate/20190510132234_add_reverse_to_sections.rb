class AddReverseToSections < ActiveRecord::Migration[5.2]
  def change
    add_column :sections, :reverse, :boolean, null: false, default: false, after: :viewport
  end
end
