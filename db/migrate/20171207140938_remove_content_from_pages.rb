class RemoveContentFromPages < ActiveRecord::Migration
  def change
    remove_column :pages, :content, :text, after: :metadata
  end
end
