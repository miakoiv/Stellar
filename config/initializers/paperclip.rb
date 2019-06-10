
Paperclip.options[:command_path] = '/usr/bin'
Paperclip.options[:content_type_mappings] = {
  dwg: %w(text/plain application/octet-stream),
  scss: 'text/plain',
  xls: %w(application/vnd.ms-excel application/xml text/xml),
  xml: %w(application/xml text/xml),
}
