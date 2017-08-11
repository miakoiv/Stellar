class RenameLayoutToOutlineInSections < ActiveRecord::Migration
  def change
    rename_column :sections, :layout, :outline
  end
end
