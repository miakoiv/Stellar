class DropCategoriesUsersJoinTable < ActiveRecord::Migration
  def change
    drop_join_table :categories, :users do |t|
      t.index [:category_id, :user_id], unique: true
    end
  end
end
