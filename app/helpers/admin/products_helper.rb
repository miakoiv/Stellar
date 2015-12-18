#encoding: utf-8

module Admin::ProductsHelper

  def product_count(count, total)
    "#{title(Product, count: 2)}: #{count}/#{total}"
  end
end
