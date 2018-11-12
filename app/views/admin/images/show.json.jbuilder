json.extract! @image, :id, :attachment_file_name, :attachment_content_type, :attachment_file_size
json.select_url select_admin_image_path(@image)
