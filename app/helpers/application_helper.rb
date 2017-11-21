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
      description: object.description.presence
    }
    set_meta_tags(og: tags)
  end

  def dropdown_toggle
    content_tag :a, data: {toggle: 'dropdown'}, role: 'button', tabindex: 0 do
      yield
    end
  end

  def menu_title(icon, text)
    icon(icon, text, class: 'fa-fw')
  end

  def menu_item(icon, text, path, options = {})
    active_link_to menu_title(icon, text), path, options.merge(wrap_tag: :li)
  end

  def tab_set(id, options = {})
    classes = (options[:class] || '').split
    classes << 'nav nav-tabs'
    options[:class] = classes.join(' ')
    content_tag :ul, options.merge(id: id, role: 'tablist') do
      yield
    end
  end

  def nav_tab(id, text, options = {})
    href = "#tab-#{id}"
    classes = (options[:class] || '').split
    classes << 'active' if options.delete(:default)
    options[:class] = classes.join(' ')
    content_tag :li, options.merge(role: 'presentation') do
      link_to text, href, role: 'tab', data: {toggle: 'tab'}
    end
  end

  def tab_pane(id, options = {})
    id = "tab-#{id}"
    classes = (options[:class] || '').split
    classes << 'tab-pane fade'
    classes << 'in active' if options.delete(:default)
    options[:class] = classes.join(' ')
    content_tag :div, options.merge(id: id) do
      yield
    end
  end

  def bootstrap_label(object, options = {})
    appearance = options.delete(:appearance) || object.try(:appearance) || :default
    options.reverse_merge!(class: "label label-#{appearance}")
    icon = options.delete(:icon)
    text = options.delete(:text) || object.try(:label) || object.to_s
    if icon
      content_tag :span, icon(icon, text), options
    else
      content_tag :span, text, options
    end
  end

  def drag_handle
    content_tag(:span, class: 'handle', style: 'opacity: 0.5') do
      icon('ellipsis-v', class: 'fa-lg fa-fw')
    end
  end

  def blank
    "\u00a0"
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

  def background_image_style(image, size = :lightbox)
    return nil if image.nil?
    "background-image: url(#{image.url(size)})"
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

  def section_style(section)
    [].tap do |s|
      if section.background_image.present?
        s << "background-image: url(#{section.background_image.url(:lightbox)})"
      end
      s << "background-color: #{section.background_color}"
    end.join '; '
  end

  def segment_style(segment)
    "min-height: #{segment.min_height}em;" if segment.min_height.present?
  end

  # Generates a segment content id in a specific context. Scripts that
  # generate segment content may use this method to target the segment
  # content either in layout or the layout panel.
  def segment_content_id(segment, context)
    [context, segment.template, dom_id(segment)].join '_'
  end

  def branding(object)
    image_variant_tag(object.cover_image, :technical) +
      content_tag(:span, object.to_s)
  end

  def number_with_precision_and_sign(number, options = {})
    if number < 0
      "-#{number_with_precision(-number, options)}"
    else
      "+#{number_with_precision(number, options)}"
    end
  end

  def number_to_signed_percentage(number, options = {})
    if number < 0
      "-#{number_to_percentage(-number, options)}"
    else
      "+#{number_to_percentage(number, options)}"
    end
  end
end
