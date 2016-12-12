class AddPriorityToHostnames < ActiveRecord::Migration
  def change
    add_column :hostnames, :priority, :integer, null: false, default: 0, after: :is_subdomain
  end
end
