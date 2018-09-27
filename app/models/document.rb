#encoding: utf-8

class Document < ActiveRecord::Base

  include Trackable
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
        %r{\Aapplication/(octet-stream|zip)},
        %r{\Aimage/(bmp|jpeg|jpg|png|x-png|svg|vnd\.dwg)},
      ]
    }

  #---
  def is_pdf?
    !!(attachment_content_type =~ /\Aapplication\/pdf/)
  end

  def is_text?
    !!(attachment_content_type =~ /(msword|wordprocessingml\.document|opendocument\.text)/)
  end

  def is_spreadsheet?
    !!(attachment_content_type =~ /(ms-excel|spreadsheetml\.sheet|opendocument\.spreadsheet)/)
  end

  def is_presentation?
    !!(attachment_content_type =~ /(ms-powerpoint|presentationml\.presentation|opendocument\.presentation)/)
  end

  def popuppable?
    is_pdf?
  end

  def icon
    return 'file-pdf-o' if is_pdf?
    return 'file-word-o' if is_text?
    return 'file-excel-o' if is_spreadsheet?
    return 'file-powerpoint-o' if is_presentation?
    'file-o'
  end
end
