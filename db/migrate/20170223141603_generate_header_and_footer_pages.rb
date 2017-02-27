class GenerateHeaderAndFooterPages < ActiveRecord::Migration

  # Generates one header and one footer page for each store
  # that doesn't have them yet. Then relocates all existing
  # route, primary and secondary pages under them, repurposing
  # secondary pages as primary.
  def up
    Store.all.each do |store|
      header = store.pages.header.first_or_create title: "#{store} header"
      footer = store.pages.footer.first_or_create title: "#{store} footer"

      store.pages.route.update_all parent_id: header.id
      store.pages.primary.update_all parent_id: header.id
      store.pages.secondary.update_all parent_id: footer.id, purpose: Page.purposes[:primary]
    end

    Page.rebuild!(false)
  end

  # Tearing down the above migration detaches all pages from headers
  # and footers and gives them back their original purpose.
  def down
    Page.header.each do |header|
      Page.where(parent_id: header.id).update_all parent_id: nil
      header.destroy
    end
    Page.footer.each do |footer|
      Page.where(parent_id: footer.id).update_all parent_id: nil, purpose: Page.purposes[:secondary]
      footer.destroy
    end

    Page.rebuild!(false)
  end
end
