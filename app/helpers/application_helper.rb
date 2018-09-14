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
      image: object.cover_picture.present? ? image_url(object.cover_picture.image.url(:presentational, timestamp: false)) : nil,
      description: object.description.presence
    }
    set_meta_tags(og: tags)
  end

  # Product header based on given item, which should respond to
  # #product, #product_title, #product_subtitle, #product_code
  def product_header(item)
    content_tag(:div, class: 'product') do
      concat link_to(item.product_title, admin? ? admin_product_path(item.product) : show_product_path(item.product))
      if item.real?
        concat content_tag(:span, item.product_code, class: 'badge', title: item.product_customer_code, data: {toggle: 'tooltip', placement: 'right'})
      end
      concat content_tag(:div, item.product_subtitle, class: 'small')
    end
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
    c = Array.wrap(options.delete(:class)).reject { |c| c.in? [true, false] }
    c << 'nav nav-tabs'
    options[:class] = c.join(' ')
    content_tag :ul, options.merge(id: id, role: 'tablist') do
      yield
    end
  end

  def nav_tab(id, text, options = {})
    href = "#tab-#{id}"
    c = Array.wrap(options.delete(:class)).reject { |c| c.in? [true, false] }
    c << 'active' if options.delete(:default)
    options[:class] = c.join(' ')
    content_tag :li, options.merge(role: 'presentation') do
      link_to text, href, role: 'tab', data: {toggle: 'tab'}
    end
  end

  def tab_pane(id, options = {})
    id = "tab-#{id}"
    c = Array.wrap(options.delete(:class)).reject { |c| c.in? [true, false] }
    c << 'tab-pane fade'
    c << 'in active' if options.delete(:default)
    options[:class] = c.join(' ')
    content_tag :div, options.merge(id: id) do
      yield
    end
  end

  def bootstrap_label(object, options = {})
    appearance = options.delete(:appearance) || object.try(:appearance) || :default
    options.reverse_merge!(class: "label label-#{appearance}")
    icon = options.delete(:icon) || object.try(:icon)
    text = options.delete(:text) || object.try(:label) || object.to_s
    if icon
      content_tag :span, icon(icon, text), options
    else
      content_tag :span, text, options
    end
  end

  def life_pro_tip(object)
    appearance, message = object.life_pro_tip
    return nil if message.nil?
    content_tag :div, id: 'life-pro-tip', class: 'hidden-print' do
      content_tag :div, class: "alert alert-#{appearance}", role: 'alert' do
        t("tips.#{object.model_name.i18n_key}#{message}").html_safe
      end
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

  def picture_variant_tag(picture, size = :icon, options = {})
    return ''.html_safe if picture.nil?
    image_variant_tag(picture.image, size, options)
  end

  # image_tag that supports size variants and non-bitmaps.
  def image_variant_tag(image, size = :icon, options = {})
    return ''.html_safe if image.nil?
    if image.is_bitmap?
      image_tag(image.url(size), options.merge(image.dimensions(size)))
    else
      image_tag(image.url(:original), options.merge(class: 'img-responsive'))
    end
  end

  # Document icon with a tooltip.
  def document_icon_tag(document)
    icon(document.icon, class: 'fa-lg icon', title: document.attachment_file_name, data: {toggle: 'tooltip'})
  end

  def branding(object)
    picture_variant_tag(object.cover_picture, :technical) +
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

  def number_if_present(number, prefix = nil)
    number == 0 ? '' : "#{prefix}#{number}"
  end

  def column_class(column)
    ['column', column.alignment, column.pivot? && 'pivot'].join ' '
  end

  # Converts given styles hash to a string of CSS rules.
  def css(styles)
    styles.reject { |_, rule| rule.nil? }.map { |key, rule|
      selector = key.to_s.underscore.dasherize
      "#{selector}: #{rule};"
    }.join ' '
  end

  def background_picture_style(picture, size = :lightbox)
    return {} if picture.nil?
    {
      backgroundImage: "url(#{picture.image.url(size, timestamp: false)})"
    }
  end

  def background_color_style(element)
    if element.respond_to?(:gradient_type) && element.gradient_type.present?
      {
        backgroundImage: build_gradient(element.gradient_type, element.gradient_direction, element.background_color, element.gradient_color, element.gradient_balance.to_i)
      }
    else
      {backgroundColor: element.background_color.presence}
    end
  end

  def segment_style(segment)
    {
      minHeight: segment.min_height.present? ? "#{segment.min_height}em" : nil
    }
  end

  def build_gradient(type, direction, start_color, stop_color, balance)
    to = direction.humanize(capitalize: false)
    at = to.present? ? "at #{to}" : ''
    start = balance > 0 ? balance : 0
    stop = balance < 0 ? 100 + balance : 100
    color_stops = "#{start_color} #{start}%, #{stop_color} #{stop}%"
    if type == 'linear'
      "linear-gradient(to #{to}, #{color_stops})"
    else
      "radial-gradient(#{type} #{at}, #{color_stops})"
    end
  end
end
