#
# Content generation takes a segment and updates its content
# attribute with a plain text representation.
#
class ContentGenerationJob < ApplicationJob
  queue_as :default

  def perform(segment)
    content = if segment.has_content?
      html = Nokogiri::HTML(segment.body)
      html.search('//text()').map(&:text).join(' ')
    else
      nil
    end
    segment.update_columns content: content
  end
end
