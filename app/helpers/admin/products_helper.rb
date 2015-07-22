#encoding: utf-8

module Admin::ProductsHelper

  # Returns the name of the tab product resides on in product index.
  def products_tab(product)
    product.category.nil? ? 'uncategorized' : ''
  end
end
