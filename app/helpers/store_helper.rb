#encoding: utf-8

module StoreHelper

  def link_to_all_products
    content_tag(:div, nil, class: 'corner') +
    link_to('★', show_all_products_path, class: 'corner-link')
  end

end
