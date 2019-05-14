# This partial provides a segment representation without an id to be included
# in segments attributes as part of a larger structure.
json.extract! segment, :resource_id, :resource_type, :template, :shape, :alignment, :margin_top, :margin_bottom, :padding_vertical, :padding_horizontal, :foreground_color, :background_color, :body, :metadata, :inline_styles

if segment.pictures.any?
  json.pictures_attributes do
    json.array! segment.pictures, partial: 'admin/pictures/copy', as: :picture
  end
end
