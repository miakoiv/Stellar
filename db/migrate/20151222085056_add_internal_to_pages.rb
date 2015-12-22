class AddInternalToPages < ActiveRecord::Migration
  def change
    add_column :pages, :internal, :boolean, null: false, default: false, after: :content
  end
end
