module Admin::ShipmentsHelper

  def metadata_table(parsed_metadata)
    content_tag(:dl, class: 'dl-horizontal') do
      parsed_metadata.map do |k, v|
        next if v.blank? || v.is_a?(Array)
        content_tag(:dt, k) + content_tag(:dd, v)
      end.join.html_safe
    end
  end
end
