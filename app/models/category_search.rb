#encoding: utf-8
#
# This search is suited for finding navigable categories,
# which means categories that have an associated page as
# a descendant of the store header.
#
require 'searchlight/adapters/action_view'

class CategorySearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    Category.joins(:page).order(:lft)
  end

  def search_store
    query.where(store: store)
  end

  def search_within
    query.where(
      'pages.lft >= ? AND pages.lft < ?',
      within.lft, within.rgt
    )
  end

  def search_keyword
    query.where('name LIKE ?', "%#{keyword}%")
  end

  def search_live
    query.where(live: live)
  end
end
