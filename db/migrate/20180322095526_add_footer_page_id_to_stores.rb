class AddFooterPageIdToStores < ActiveRecord::Migration
  def change
    add_reference :stores, :footer_page, after: :theme
  end
end
