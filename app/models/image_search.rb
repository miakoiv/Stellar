#encoding: utf-8

require 'searchlight/adapters/action_view'

class ImageSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  #---
  def base_query
    Image.includes(:pictures)
  end

  def search_store
    query.where(store: store)
  end

  def search_keyword
    query.where('attachment_file_name LIKE ?', "%#{keyword}%")
  end
end
