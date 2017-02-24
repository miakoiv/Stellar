module AwesomeNester
  extend ActiveSupport::Concern

  # POST /admin/nestable/rearrange
  def rearrange
    params[:rearrange].each do |key, items|
      klass = key.classify.constantize
      klass.transaction do
        rearrange_recursively klass, items
      end
    end
    render nothing: true
  end

  private
    # Rearranges items of klass recursively in a nested set, where
    # items is an array of hashes of record id and optional children,
    # as serialized by jquery-nestable.
    def rearrange_recursively(klass, items, parent = nil)
      last = nil
      items.each do |item|
        record = klass.find(item['id'])
        if last
          record.move_to_right_of(last)
        else
          parent ? record.move_to_child_of(parent) : record.move_to_root
        end
        last = record
        if item['children']
          rearrange_recursively klass, item['children'], record
        end
      end
    end
end
