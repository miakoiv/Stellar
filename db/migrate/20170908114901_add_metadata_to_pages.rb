class AddMetadataToPages < ActiveRecord::Migration
  def change
    add_column :pages, :metadata, :text, after: :slug
  end
end
