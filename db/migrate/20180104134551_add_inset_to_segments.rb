class AddInsetToSegments < ActiveRecord::Migration
  def change
    add_column :segments, :inset, :string, null: false, default: 'inset-none', after: :alignment
  end
end
