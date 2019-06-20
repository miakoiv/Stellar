class AddSpanXsSpanSmToColumns < ActiveRecord::Migration[5.2]
  def up
    add_column :columns, :span_xs, :integer, null: false, default: 12, after: :section_id
    add_column :columns, :span_sm, :integer, null: false, default: 12, after: :span_xs

    Section.find_each(batch_size: 50) do |section|
      spans = Section::SPANS[section.layout]
      next if spans.nil?
      section.columns.each_with_index do |column, i|
        xs = spans[:xs][i] or next
        sm = spans[:sm][i] or next
        column.update_columns(span_xs: xs, span_sm: sm)
      end
    end
  end

  def down
    remove_column :columns, :span_xs
    remove_column :columns, :span_sm
  end
end
