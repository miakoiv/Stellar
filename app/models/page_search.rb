class PageSearch < Searchlight::Search

  def base_query
    Page.joins(:segments)
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
    query.primary.live.distinct.where('segments.content LIKE ?', "%#{keyword}%")
  end
end
