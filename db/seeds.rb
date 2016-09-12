# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#-----------------------------------------------------------------------------
# General inventory with fuzzy availability, and order types for delivery
# with or without online payment.
#
Inventory.create(id: 1, fuzzy: true, name: 'Saatavuus', inventory_code: 'VART')

OrderType.create(
  id: 1,
  store_id: 1,
  name: 'Maksu laskulla',
  has_shipping: true,
  has_payment: false
)
OrderType.create(
  id: 2,
  store_id: 1,
  name: 'Maksu verkkomaksuna',
  has_shipping: true,
  has_payment: true
)

#-----------------------------------------------------------------------------
# Tikkurila
#
Store.create(
  id: 1,
  host: 'tjt-extranet.leasit.info',
  erp_number: 1545,
  name: 'Tikkurila',
  theme: 'cards'
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
  password: 'interior thin pale character',
  role_ids: [1,2,3,10,12,13,14,15,16,17,18,19,99],
)
User.create(
  store_id: 1,
  name: 'Mikko Kaukojärvi',
  email: 'mikko.kaukojarvi@tjt-kaluste.fi',
  password: 'powerrangers',
  role_ids: [1,2,3,10,11,12,13,14,15,16,17,18,19],
)
