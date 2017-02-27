class RepurposePages < ActiveRecord::Migration
  def up
    Page.where(purpose: 5).update_all purpose: 12
    Page.where(purpose: 7).update_all purpose: 10
    Page.where(purpose: 8).update_all purpose: 11
  end

  def down
    Page.where(purpose: 10).update_all purpose: 7
    Page.where(purpose: 11).update_all purpose: 8
    Page.where(purpose: 12).update_all purpose: 5
  end
end
