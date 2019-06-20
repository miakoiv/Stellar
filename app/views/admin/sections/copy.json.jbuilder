json.section do
  # Copying a section and all its columns and segments without primary keys
  # or page association to provide a representation compatible with
  # nested attributes.
  json.extract! @section, :width, :gutters, :swiper, :viewport, :reverse, :background_color, :gradient_color, :gradient_type, :gradient_direction, :gradient_balance, :fixed_background, :inline_styles

  if @section.pictures.any?
    json.pictures_attributes do
      json.array! @section.pictures, partial: 'admin/pictures/copy', as: :picture
    end
  end

  json.columns_attributes do
    json.array! @section.columns, partial: 'admin/columns/copy', as: :column
  end
end
