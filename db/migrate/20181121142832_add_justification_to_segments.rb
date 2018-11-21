class AddJustificationToSegments < ActiveRecord::Migration
  def change
    add_column :segments, :justification, :string, null: false, default: 'justify-center', after: :alignment
  end
end
