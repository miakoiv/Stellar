json.extract! column, :alignment, :viewport, :pivot, :background_color, :inline_styles, :priority

if column.pictures.any?
  json.pictures_attributes do
    json.array! column.pictures, partial: 'admin/pictures/copy', as: :picture
  end
end

json.segments_attributes do
  json.array! column.segments, partial: 'admin/segments/copy', as: :segment
end
