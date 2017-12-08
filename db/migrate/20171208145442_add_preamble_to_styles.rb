class AddPreambleToStyles < ActiveRecord::Migration
  def change
    add_column :styles, :preamble, :text, after: :stylesheet_file_name
  end
end
