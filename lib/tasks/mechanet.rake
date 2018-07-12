#encoding: utf-8

require 'creek'

namespace :properties do
  desc "Import Mechanet property definitions"
  task :mechanet, [:file] => :environment do |task, args|

    # Lookup table for existing measurement units.
    units = MeasurementUnit.all.map { |u| [u.name.parameterize, u] }.to_h

    # Nuke existing properties before creating fresh records.
    store = Store.find_by name: 'Mechanet'
    store.properties.destroy_all

    # Input file has the known properties in column B,
    # where the original name becomes the external name for the property
    # before attempting to extract a measurement unit in parens, which may
    # not match.
    xlsx = Creek::Book.new args.file
    sheet = xlsx.sheets[0]
    i = 0
    sheet.rows.each do |row|
      row.each do |col, name|
        next if col.first == 'A' || col == 'B1'
        match = /\(([^)]+)\)\z/.match(name)
        unit = match && units[match[1].gsub(/\d+/, '').parameterize]
        if unit
          uname = name.sub(/\s*\([^)]+\)\z/, '')
          store.properties.create(
            name: uname,
            external_name: name,
            value_type: 'numeric',
            measurement_unit: unit,
            priority: i
          )
        else
          store.properties.create(
            name: name,
            external_name: name,
            value_type: 'string',
            priority: i
          )
        end
        i += 1
      end
    end
  end
end

namespace :products do
  desc "Import Mechanet product data"
  task :mechanet, [:file] => :environment do |task, args|
    puts args.file
    store = Store.find_by name: 'Mechanet'
    tax_category = store.tax_categories.first
    property_map = store.property_map

    xlsx = Creek::Book.new args.file
    xlsx.sheets.each do |sheet|
      puts "[<] Sheet #{sheet.name}"
      rows = sheet.rows.each
      columns = rows.next.values
      category = nil
      loop do
        row = rows.next.values
        next if row.empty?
        data = columns.zip(row).to_h
        category ||= find_or_create_category(store, data)
        product = find_or_create_product(store, category, tax_category, data)
        assign_properties(product, data, property_map)
      end
    end
  end

  # Updates (or creates) a product from given data.
  def find_or_create_product(store, category, tax_category, data)
    code = data['Code Mechanet']
    product = store.products.find_or_initialize_by(code: code)
    product.customer_code = data['Toimittaja koodi']
    product.title = data['Tuotenimi']
    product.subtitle = data['Materiaali']
    product.available_at ||= Date.current
    product.retail_price = data['Ulosmyyntihinta EUR']
    product.trade_price = data['Toimittajan hinta 2018']
    product.categories = [category]
    product.tax_category = tax_category
    puts "[%s] %-16s" % [product.new_record? ? '+' : '–', code]
    product.save!
    product
  end

  # Finds the category matching given data, creating it on demand.
  def find_or_create_category(store, data)
    parent = store.categories.find_or_create_by!(name: data['Päätuoteryhmän nimi'], product_scope: :alphabetical)
    store.categories.find_or_create_by!(name: data['Alatuoteryhmän nimi'], parent: parent, product_scope: :alphabetical)
  end

  # Assigns product properties to the given product from data,
  # using the supplied property map.
  def assign_properties(product, data, property_map)
    properties = property_map
      .select { |c, _| data[c.to_s].present? }
      .map { |c, p|
        v = data[c.to_s]
        ProductProperty.new(
          property: p,
          value: p.numeric? ? v.to_s.sub('.', ',') : v.to_s
        )
      }
    product.product_properties = properties
  end
end
