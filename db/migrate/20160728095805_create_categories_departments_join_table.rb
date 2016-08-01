class CreateCategoriesDepartmentsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :categories, :departments do |t|
      t.index [:category_id, :department_id], unique: true
    end
  end
end
