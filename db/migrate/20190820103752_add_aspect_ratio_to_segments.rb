class AddAspectRatioToSegments < ActiveRecord::Migration[5.2]
  def up
    add_column :segments, :aspect_ratio, :string, after: :shape

    # Update existing segments with aspect ratios using the shapes mapping
    # in reverse to turn 'shape-16-9' into '16:9'.
    ratios = Segment::SHAPES.map { |name, id| [id, name.split.first] }.to_h
    Segment.unscoped.where.not(shape: [nil, '']).each do |segment|
      segment.update_columns aspect_ratio: ratios[segment.shape]
    end
  end

  def down
    remove_column :segments, :aspect_ratio, :string, after: :shape
  end
end
