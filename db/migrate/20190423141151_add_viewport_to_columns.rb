class AddViewportToColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :columns, :viewport, :boolean, null: false, default: false, after: :alignment
  end
end
