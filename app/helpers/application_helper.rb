#encoding: utf-8

module ApplicationHelper

  def blank_option
    "\u274c" # U+274C CROSS MARK
  end

  # image_tag that supports size variants and non-bitmaps.
  def image_variant_tag(image, size = :icon, options = {})
    return '' if image.nil?
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
        image.attachment_file_name.truncate(20, omission: '…'),
        class: 'fa-2x')
    else
      icon(image.document_icon,
        image.attachment_file_name.truncate(20, omission: '…'),
        class: 'fa-3x')
    end
  end

  # Display icon with name, using cover image as the icon.
  def name_with_icon(object)
    image_variant_tag(object.cover_image) + " #{object.name}"
  end

  def tr_placeholder(colspan)
    content_tag(:tr, content_tag(:td, icon('hand-o-right'), colspan: colspan))
  end

  def list_group_placeholder
    content_tag(:div, content_tag(:p, icon('hand-o-right')), class: 'list-group-item')
  end

  # Pretty-prints a stock lookup hash.
  def product_stock_string(stock)
    stock.map do |i, s|
      content_tag(:span, class: i, title: i, data: {toggle: 'tooltip'}) do
        content_tag(:span, s[:adjustment] == 0 ? s[:current] :
          sprintf("%i(%+i)", s[:current], s[:adjustment]))
      end
    end.join.html_safe
  end
end
