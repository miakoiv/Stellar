# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ImageType.create(purpose: 'presentational', name: 'Presentational')
ImageType.create(purpose: 'technical', name: 'Technical')
ImageType.create(purpose: 'document', name: 'Document', bitmap: false)

Store.create(
  erp_number: 1545,
  name: 'Tikkurila'
)
Category.create(store_id: 1, name: 'Color Display')
Category.create(store_id: 1, name: 'Product Placement')
Category.create(store_id: 1, name: 'Shop Event Material')
Category.create(store_id: 1, name: 'Visio')
Category.create(store_id: 1, name: 'Duett')
Category.create(store_id: 1, name: 'Tinting Area')

User.create(
  store_id: 1,
  email: 'rosenblad@gmail.com',
  password: 'rush2112'
)
User.create(
  store_id: 1,
  email: 'mikko.kaukojarvi@tjt-kaluste.fi',
  password: 'powerrangers'
)

Store.create(
  erp_number: 110007,
  name: 'Intersport Finland'
)

Category.create(store_id: 2, name: 'Sokkelit')
Category.create(store_id: 2, name: 'Korit')
Category.create(store_id: 2, name: 'Modifiointiosat')
Category.create(store_id: 2, name: 'Keskilattiakalusteet')
Category.create(store_id: 2, name: 'Palvelupisteet')
Category.create(store_id: 2, name: 'Jalkine')
Category.create(store_id: 2, name: 'Sovituskopit')
Category.create(store_id: 2, name: 'Kassat')
Category.create(store_id: 2, name: 'Paneeliseinä')
Category.create(store_id: 2, name: 'Muut kalusteet')

Inventory.create(purpose: 'manufacturing', name: 'Manufacturing')
Inventory.create(purpose: 'shipping', name: 'Shipping')

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
