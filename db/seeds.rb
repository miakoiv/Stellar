# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(
  brand_id: 1,
  email: 'rosenblad@gmail.com',
  password: 'rush2112'
)

Brand.create(name: 'Tikkurila Oyj')

Inventory.create(brand_id: 1, name: 'Manufacturing')
Inventory.create(brand_id: 1, name: 'Shipping')

OrderType.create(
  inventory_id: 1,
  adjustment_multiplier: 1,
  name: 'Manufacturing'
)
OrderType.create(
  inventory_id: 2,
  adjustment_multiplier: -1,
  name: 'Shipping'
)
