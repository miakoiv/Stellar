class CreateCategoriesGroupsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :categories, :groups do |t|
      t.index :group_id
    end
  end
end
