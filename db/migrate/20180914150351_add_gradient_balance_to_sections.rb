class AddGradientBalanceToSections < ActiveRecord::Migration
  def change
    add_column :sections, :gradient_balance, :integer, null: false, default: 0, after: :gradient_direction
  end
end
