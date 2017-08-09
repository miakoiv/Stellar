class RemoveAspectRatioFromSections < ActiveRecord::Migration
  def change
    remove_column :sections, :aspect_ratio, :string, after: :layout
  end
end
