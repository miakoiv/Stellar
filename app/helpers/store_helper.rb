#encoding: utf-8

module StoreHelper

  def property_string(product_properties)
    product_properties.map { |pp|
      content_tag(:span, pp.value, class: 'label label-default')
    }.join(' ').html_safe
  end
end
