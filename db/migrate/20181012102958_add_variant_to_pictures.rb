class AddVariantToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :variant, :string, after: :purpose
  end
end
