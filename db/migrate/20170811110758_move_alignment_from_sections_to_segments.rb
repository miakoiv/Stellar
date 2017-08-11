class MoveAlignmentFromSectionsToSegments < ActiveRecord::Migration
  def change
    add_column :segments, :alignment, :string, null: false, default: 'align-top', after: :template
    remove_column :sections, :alignment, :string, null: false, default: 'none', after: :height
  end
end
