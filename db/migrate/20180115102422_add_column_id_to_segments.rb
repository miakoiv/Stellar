class AddColumnIdToSegments < ActiveRecord::Migration
  def up
    add_reference :segments, :column, null: false, index: true, after: :section_id

    Segment.reset_column_information
    Section.find_each(batch_size: 25) do |section|
      section.segments.each do |segment|
        column = section.columns.create(
          alignment: segment.alignment,
          priority: segment.priority
        )
        segment.update_columns(priority: 0)
        column.segments << segment
      end
    end
  end

  def down
    remove_reference :segments, :column
  end
end
