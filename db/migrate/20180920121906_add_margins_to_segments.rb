class AddMarginsToSegments < ActiveRecord::Migration
  def up
    add_column :segments, :margin_top, :integer, null: false, default: 0, after: :alignment
    add_column :segments, :margin_bottom, :integer, null: false, default: 0, after: :margin_top

    Column.joins(:section).where(sections: {gutters: true}).find_each(batch_size: 20) do |column|
      segments = column.segments
      next unless segments.any?
      segments.first.update(margin_top: 40)
      segments.last.update(margin_bottom: 40)
    end
  end

  def down
    remove_column :segments, :margin_top
    remove_column :segments, :margin_bottom
  end
end
