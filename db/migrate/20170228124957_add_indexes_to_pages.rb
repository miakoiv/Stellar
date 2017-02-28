class AddIndexesToPages < ActiveRecord::Migration
  def change
    add_index :pages, :lft
    add_index :pages, :rgt
    add_index :pages, :depth
  end
end
