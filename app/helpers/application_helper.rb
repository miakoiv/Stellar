#encoding: utf-8

module ApplicationHelper

  def title(klass, options = {})
    klass.model_name.human(options).capitalize
  end

  def col(klass, attribute_name)
    klass.human_attribute_name(attribute_name)
  end

  def meta_tags_for(object)
    tags = {
      title: object.to_s,
      url: request.original_url,
      image: object.cover_image.present? ? image_url(object.cover_image.url(:presentational)) : nil,
      description: object.description.present? ? Nokogiri::HTML(object.description).css('body').children.map(&:text).join("\n") : nil
    }
    set_meta_tags(og: tags)
  end

  def drag_handle
    content_tag(:span, class: 'handle', style: 'opacity: 0.5') do
      icon('ellipsis-v', class: 'fa-lg fa-fw')
    end
  end

  def loading_spinner
    icon('chevron-down', id: 'spinner', class: 'animated infinite flip', style: 'display: none')
  end

  # image_tag that supports size variants and non-bitmaps.
  def image_variant_tag(image, size = :icon, options = {})
    return ''.html_safe if image.nil?
    if image.is_bitmap?
      image_tag(image.url(size), options.merge(image.dimensions(size)))
    elsif image.is_vector?
      image_tag(image.url(:original), options.merge(class: 'img-responsive'))
    else
      document_icon_tag(image, size)
    end
  end

  # Different sized icons for documents and video files.
  # Comes with a tooltip of the file name.
  def document_icon_tag(image, size = :icon)
    case size
    when :icon
      icon(image.document_icon, class: 'fa-lg icon', title: image.attachment_file_name, data: {toggle: 'tooltip'})
    when :thumbnail
      icon(image.document_icon, image.attachment_file_name.truncate(10, omission: '…'), class: 'fa-2x', title: image.attachment_file_name, data: {toggle: 'tooltip'})
    else
      icon(image.document_icon, image.attachment_file_name.truncate(20, omission: '…'), class: 'fa-3x', title: image.attachment_file_name, data: {toggle: 'tooltip'})
    end
  end

  def branding(object)
    image_variant_tag(object.cover_image, :technical) +
      content_tag(:span, object.to_s)
  end

  def order_type_label(order_type, user)
    "#{order_type.incoming_for?(user) ? '↘' : '↖'} #{order_type.to_s}"
  end
end
