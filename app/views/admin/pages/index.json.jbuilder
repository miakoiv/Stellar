json.array!(@pages) do |page|
  json.extract! page, :id, :store_id, :parent_page_id, :title, :content
  json.url page_url(page, format: :json)
end
