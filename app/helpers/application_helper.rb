#encoding: utf-8

module ApplicationHelper

  def title(klass, options = {})
    klass.model_name.human(options).capitalize
  end

  def col(klass, attribute_name)
    klass.human_attribute_name(attribute_name)
  end

  def drag_handle
    content_tag(:span, class: 'handle', style: 'opacity: 0.5') do
      icon('ellipsis-v', class: 'fa-lg fa-fw')
    end
  end

  # image_tag that supports size variants and non-bitmaps.
  def image_variant_tag(image, size = :icon, options = {})
    return ''.html_safe if image.nil?
    if image.is_bitmap?
      image_tag(image.url(size), options)
    else
      document_icon_tag(image, size)
    end
  end

  # Different sized icons for documents.
  # Comes with a tooltip of the file name.
  def document_icon_tag(image, size = :icon)
    case size
    when :icon
      icon(image.document_icon, class: 'fa-lg icon',
        title: image.attachment_file_name,
        data: {toggle: 'tooltip'})
    when :thumbnail
      icon(image.document_icon,
        image.attachment_file_name.truncate(10, omission: '…'),
        class: 'fa-2x')
    else
      icon(image.document_icon,
        image.attachment_file_name.truncate(20, omission: '…'),
        class: 'fa-3x')
    end
  end

  def branding(store)
    image_variant_tag(store.cover_image, :matchbox) +
      content_tag(:span, store.to_s)
  end

  def tr_placeholder(colspan)
    content_tag(:tr, content_tag(:td, icon('hand-o-right'), colspan: colspan))
  end

  def list_group_placeholder
    content_tag(:div, content_tag(:p, icon('hand-o-right')), class: 'list-group-item')
  end

  def unit_price_string(price, unit)
    "#{number_to_currency(price, unit: '€')} / #{unit}"
  end

  # Pretty-prints a hash from Product#stock.
  def product_stock_string(hash)
    hash.values.map do |i|
      content_tag(:span, class: i.klass, title: i.title, data: {toggle: 'tooltip'}) do
        content_tag(:span, i.adjustment == 0 ? i.amount || 0 :
          sprintf("%i(%+i)", i.amount || 0, i.adjustment))
      end
    end.join.html_safe
  end
end
