# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.create(id: 1, name: 'site_manager')
Role.create(id: 2, name: 'site_monitor')
Role.create(id: 3, name: 'store_manager')
Role.create(id: 4, name: 'sales_rep')
Role.create(id: 5, name: 'customer')
Role.create(id: 6, name: 'guest')

ImageType.create(purpose: 'presentational', name: 'Presentational')
ImageType.create(purpose: 'technical', name: 'Technical')
ImageType.create(purpose: 'document', name: 'Document', bitmap: false)

#-----------------------------------------------------------------------------
# General inventory with fuzzy availability, and order types for delivery
# with or without online payment.
#
Inventory.create(id: 1, purpose: 'shipping', fuzzy: true, name: 'Saatavuus')

OrderType.create(
  id: 1,
  inventory_id: 1,
  adjustment_multiplier: -1,
  name: 'Maksu laskulla',
  has_shipping: true,
  has_payment: false
)
OrderType.create(
  id: 2,
  inventory_id: 1,
  adjustment_multiplier: -1,
  name: 'Maksu verkkomaksuna',
  has_shipping: true,
  has_payment: true
)

#-----------------------------------------------------------------------------
# Inventories without fuzziness in stock availability.
# Order types include manufacturing and shipping without online payment.
#
Inventory.create(
  id: 2,
  purpose: 'manufacturing',
  fuzzy: false,
  name: 'In manufacturing queue'
)
Inventory.create(
  id: 3,
  purpose: 'shipping',
  fuzzy: false,
  name: 'Available for shipping'
)

OrderType.create(
  id: 3,
  inventory_id: 2,
  adjustment_multiplier: 1,
  name: 'Manufacture products',
  has_shipping: false,
  has_payment: false
)
OrderType.create(
  id: 4,
  inventory_id: 3,
  adjustment_multiplier: -1,
  name: 'Ship products',
  has_shipping: true,
  has_payment: false
)

#-----------------------------------------------------------------------------
# Tikkurila
#
Store.create(
  id: 1,
  contact_person_id: 2,
  host: 'tjt-extranet.leasit.info',
  erp_number: 1545,
  inventory_code: 'VART',
  name: 'Tikkurila',
  theme: 'cards',
  inventory_ids: [2,3]
)

Category.create(store_id: 1, name: 'Color Display')
Category.create(store_id: 1, name: 'Product Placement')
Category.create(store_id: 1, name: 'Shop Event Material')
Category.create(store_id: 1, name: 'Visio')
Category.create(store_id: 1, name: 'Duett')
Category.create(store_id: 1, name: 'Tinting Area')

User.create(
  store_id: 1,
  name: 'Sami Rosenblad',
  email: 'rosenblad@gmail.com',
  password: 'rush2112',
  role_ids: [1],
)
User.create(
  store_id: 1,
  name: 'Mikko Kaukojärvi',
  email: 'mikko.kaukojarvi@tjt-kaluste.fi',
  password: 'powerrangers',
  role_ids: [3],
)

#-----------------------------------------------------------------------------
# Intersport Finland
#
Store.create(
  id: 2,
  contact_person_id: 2,
  erp_number: 110007,
  name: 'Intersport Finland',
  theme: 'default',
  inventory_ids: [1]
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
