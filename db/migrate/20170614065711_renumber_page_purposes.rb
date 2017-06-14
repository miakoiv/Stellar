class RenumberPagePurposes < ActiveRecord::Migration
  def up
    Page.where(purpose: 4).update_all purpose: 30
    Page.where(purpose: 6).update_all purpose: 2
    Page.where(purpose: 7).update_all purpose: 3
    Page.where(purpose: 8).update_all purpose: 4
    Page.where(purpose: 12).update_all purpose: 20
  end

  def down
    Page.where(purpose: 20).update_all purpose: 12
    Page.where(purpose: 4).update_all purpose: 8
    Page.where(purpose: 3).update_all purpose: 7
    Page.where(purpose: 2).update_all purpose: 6
    Page.where(purpose: 30).update_all purpose: 4
  end
end
