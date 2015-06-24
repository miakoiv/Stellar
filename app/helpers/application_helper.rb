#encoding: utf-8

module ApplicationHelper

  # Use the first image of any object as its icon.
  def icon_image(object)
    return nil if object.images.empty?
    image_tag(object.images.first.attachment.url(:icon))
  end

  def blank_option
    "\u274c" # U+274C CROSS MARK
  end

end
