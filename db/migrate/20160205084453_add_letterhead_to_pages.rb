class AddLetterheadToPages < ActiveRecord::Migration
  def change
    add_column :pages, :letterhead, :boolean, null: false, default: false, after: :content
  end
end
