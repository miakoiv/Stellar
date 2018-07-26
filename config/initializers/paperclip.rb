
Paperclip.options[:command_path] = '/usr/bin'
Paperclip.options[:content_type_mappings] = {
  dwg: %w(text/plain application/octet-stream),
  scss: 'text/plain'
}
