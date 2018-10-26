json.segment do
  # Making a copy of a segment leaves out its id and column association,
  # to be filled in when a new record is pasted in another context.
  json.extract! @segment, :resource_id, :resource_type, :template, :shape, :alignment, :margin_top, :margin_bottom, :inset, :foreground_color, :background_color, :body, :metadata, :inline_styles

  # Included pictures without ids go to pictures_attributes
  # to comply with nested attributes in params.
  if @segment.pictures.any?
    json.pictures_attributes do
      json.array!(@segment.pictures) do |picture|
        json.extract! picture, :image_id, :purpose, :caption, :url, :priority
      end
    end
  end
end
