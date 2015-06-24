# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ImageType.create(name: 'Presentational')
ImageType.create(name: 'Technical')

Brand.create(
  erp_number: 1545,
  name: 'Tikkurila',
  slug: 'tikkurila'
)

User.create(
  brand_id: 1,
  email: 'rosenblad@gmail.com',
  password: 'rush2112'
)

Category.create(brand_id: 1, name: 'Color Display')
Category.create(brand_id: 1, name: 'Product Placement')
Category.create(brand_id: 1, name: 'Shop Event Material')
Category.create(brand_id: 1, name: 'Visio')
Category.create(brand_id: 1, name: 'Duett')
Category.create(brand_id: 1, name: 'Tinting Area')

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
