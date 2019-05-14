# The segment JSON includes its id to allow pasting either a duplicate
# or a reference pointing at the original segment.
json.segment do
  json.extract! @segment, :id, :resource_id, :resource_type, :template, :shape, :alignment, :margin_top, :margin_bottom, :padding_vertical, :padding_horizontal, :foreground_color, :background_color, :body, :metadata, :inline_styles

  if @segment.pictures.any?
    json.pictures_attributes do
      json.array! @segment.pictures, partial: 'admin/pictures/copy', as: :picture
    end
  end
end
