#encoding: utf-8

module ApplicationHelper

  # Find an icon for given object.
  def icon_image(object)
    return nil if object.images.icons.empty?
    image_tag(object.images.icons.first.attachment.url(:icon))
  end

  def blank_option
    "\u274c" # U+274C CROSS MARK
  end

end
