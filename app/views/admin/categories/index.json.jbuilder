json.array!(@categories) do |category|
  json.extract! category, :id, :parent_category_id, :name
  json.url admin_category_url(category, format: :json)
end
