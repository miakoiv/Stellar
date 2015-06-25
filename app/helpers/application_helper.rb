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

end
