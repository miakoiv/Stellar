class AddSwiperToSections < ActiveRecord::Migration
  def change
    add_column :sections, :swiper, :boolean, null: false, default: false, after: :gutters
  end
end
