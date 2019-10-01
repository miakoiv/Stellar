class RenameHasPaymentToHasBillingInOrderTypes < ActiveRecord::Migration[5.2]
  def change
    rename_column :order_types, :has_payment, :has_billing
  end
end
