#encoding: utf-8

class Document < ActiveRecord::Base

  include Reorderable

  #---
  belongs_to :documentable, polymorphic: true

  default_scope { sorted }

  has_attached_file :attachment
  delegate :url, to: :attachment

  #---
  validates_attachment :attachment,
    content_type: {
      content_type: [
        %r{\Aapplication/(pdf|xml|msword|vnd\.ms-excel|vnd\.ms-powerpoint)},
        %r{\Aapplication/vnd\.openxmlformats},
        %r{\Aapplication/vnd\.oasis\.opendocument\.(text|spreadsheet|presentation)},
      ]
    }

  #---
  def icon
    case attachment_content_type
    when %r{\Aapplication/pdf}
      'file-pdf-o'
    when %r{(msword|wordprocessingml\.document|opendocument\.text)}
      'file-word-o'
    when %r{ms-excel|spreadsheetml\.sheet|opendocument\.spreadsheet}
      'file-excel-o'
    when %r{ms-powerpoint|presentationml\.presentation|opendocument\.presentation}
      'file-powerpoint-o'
    else
      'file-o'
    end
  end
end
