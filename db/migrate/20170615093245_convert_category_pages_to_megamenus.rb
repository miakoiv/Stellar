# Converts existing category pages that used to render as megamenu dropdowns
# to megamenu pages and inserts the contained items (categories or products)
# as actual category or product pages.
#
class ConvertCategoryPagesToMegamenus < ActiveRecord::Migration
  def up
    Store.all.each do |store|
      root_categories = store.categories.roots
      store.pages.category.order(:lft).each do |page|
        category = page.resource
        items = if category.present?
          category.leaf? ? category.products.visible : category.children.visible
        else
          root_categories
        end
        Page.transaction do
          items.each do |item|
            purpose = item.model_name.param_key
            item_page = store.pages.create(
              purpose: purpose,
              title: item.to_s,
              resource: item
            )
            item_page.move_to_child_of(page)
          end
          page.update(purpose: 'megamenu', resource: nil)
        end
      end
    end
  end

  def down
    Store.all.each do |store|
      store.pages.megamenu.each do |page|
        next if page.children_count == 0
        resource = page.children.first.resource
        parent = resource.is_a?(Product) ? resource.category : resource.parent
        page.children.destroy_all
        page.update(purpose: 'category', resource: parent)
      end
    end
  end
end
