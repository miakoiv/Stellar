class AddForegroundColorToSegments < ActiveRecord::Migration
  def up
    add_column :segments, :foreground_color, :string, null: false, default: '#333', after: :inset

    Segment.unscoped.text.where.not(body: nil).each do |segment|
      color = /(#[0-9a-fA-F]{3,6})|(rgba?\([^)]+\))/.match(segment.body)
      next if color.nil?
      segment.update foreground_color: color
    end
  end

  def down
    remove_column :segments, :foreground_color
  end
end
