#encoding: utf-8

module ApplicationHelper

  # Display an icon for object.
  def icon_image_tag(object)
    icon = object.icon_image
    image_tag(icon.attachment.url(:icon)) if icon.present?
  end

  def blank_option
    "\u274c" # U+274C CROSS MARK
  end

  def tr_placeholder(colspan)
    content_tag(:tr, content_tag(:td, icon('hand-o-right'), colspan: colspan))
  end

  def list_group_placeholder
    content_tag(:div, content_tag(:p, icon('hand-o-right')), class: 'list-group-item')
  end
end
