class AddGuttersToSections < ActiveRecord::Migration
  def up
    add_column :sections, :gutters, :boolean, null: false, default: true, after: :layout
    execute <<-SQL
      UPDATE sections SET gutters = outline
    SQL
  end

  def down
    remove_column :sections, :gutters
  end
end
