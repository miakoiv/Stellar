class AddLiveToPages < ActiveRecord::Migration
  def change
    add_column :pages, :live, :boolean, default: true, null: false, after: :children_count
  end
end
