class ReassignMasterAndVariantProducts < ActiveRecord::Migration
  def change
    Product.where(purpose: [1, 2]).update_all(purpose: 0)
  end
end
