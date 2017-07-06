class RemoveBannerFromCategories < ActiveRecord::Migration
  def change
    remove_reference :categories, :banner, index: true, after: :children_count
  end
end
