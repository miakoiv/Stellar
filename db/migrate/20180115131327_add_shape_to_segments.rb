class AddShapeToSegments < ActiveRecord::Migration
  def change
    add_column :segments, :shape, :string, after: :template

    Segment.reset_column_information
    Section.all.reject { |s| s.shape.blank? }.each do |section|
      section.segments.update_all shape: section.shape
    end
  end
end
