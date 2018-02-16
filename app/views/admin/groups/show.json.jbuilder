json.extract! @group, :id, :name
json.outgoing_order_types do
  json.array! @group.outgoing_order_types, :id, :name
end
