#encoding: utf-8

module ApplicationHelper

  def blank_option
    "\u274c" # U+274C CROSS MARK
  end

  # image_tag with size variant support.
  def image_variant_tag(image, size = :icon, options = {})
    return '' if image.nil?
    image_tag(image.url(size), options)
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
end
