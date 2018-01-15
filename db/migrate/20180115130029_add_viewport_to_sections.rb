class AddViewportToSections < ActiveRecord::Migration
  def up
    add_column :sections, :viewport, :boolean, null: false, default: false, after: :gutters

    Section.reset_column_information
    Section.find_each(batch_size: 50) do |section|
      section.update(viewport: section.shape == 'shape-viewport')
    end
  end

  def down
    remove_column :sections, :viewport
  end
end
