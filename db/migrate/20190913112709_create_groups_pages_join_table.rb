class CreateGroupsPagesJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :groups, :pages, column_options: {type: :integer} do |t|
      t.index [:page_id, :group_id], unique: true
    end
  end
end
