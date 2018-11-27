module Admin::SegmentsHelper
  def segment_placeholder(segment)
    content_tag(:div, class: 'placeholder') do
      content_tag(:figure) do
        image_tag "templates/#{segment.template}.svg"
      end
    end
  end
end
