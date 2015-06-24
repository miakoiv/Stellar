#encoding: utf-8

module ApplicationHelper

  # Display an icon for object.
  def icon_image(object)
    icons = object.images.by_type('Icon')
    return nil if icons.empty?
    image_tag(icons.first.attachment.url(:icon))
  end

  def blank_option
    "\u274c" # U+274C CROSS MARK
  end

end
