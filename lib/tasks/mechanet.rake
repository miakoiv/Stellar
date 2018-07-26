#encoding: utf-8

require 'creek'

DROPBOX_PATH = '/opt/dropbox/Dropbox/Mechanet_verkkokauppa'

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

namespace :images do
  desc "Import Mechanet image files"
  task :mechanet, [:path, :file] => :environment do |task, args|
    store = Store.find_by name: 'Mechanet'
    image = store.images.find_or_initialize_by(attachment_file_name: args.file)
    image.attachment = File.new("#{args.path}/#{args.file}")
    image.save!
  end
end

namespace :products do
  desc "Import Mechanet product data"
  task :mechanet, [:file] => :environment do |task, args|
    store = Store.find_by name: 'Mechanet'
    tax_category = store.tax_categories.first
    property_map = store.property_map

    xlsx = Creek::Book.new args.file
    xlsx.sheets.each do |sheet|
      puts "[<] Sheet #{sheet.name}"
      rows = sheet.rows.each_with_index
      columns = rows.next[0].values
      loop do
        row, line = rows.next
        values = row.values
        next if values.empty?
        data = columns.zip(values).to_h
        next unless data['Tuotenimi'].present?
        category = find_or_create_category(store, data)
        product = find_or_create_product(store, category, tax_category, data)
        puts "[%4d] %-16s" % [line+1, product.code]
        assign_properties(product, data, property_map)
        assign_documentation(product, "#{DROPBOX_PATH}/Mechanet_CAD_kuvat", data['CAD kuvan kuvatiedosto'])
        assign_image(store, product, 0, data['Kaaviokuvan kuvatiedosto'])
        assign_image(store, product, 1, data['Tuotekuvan kuvatiedosto'])
        product.touch
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
    product.retail_price = data['Ulosmyyntihinta EUR'].to_money
    product.trade_price = data['Toimittajan hinta 2018'].to_money
    product.categories = [category]
    product.tax_category = tax_category
    product.save!
    product
  end

  # Finds the category matching given data, creating it on demand.
  def find_or_create_category(store, data)
    parent = store.categories.find_or_create_by!(name: data['Päätuoteryhmän nimi'], product_scope: :alphabetical)
    if data['Alatuoteryhmän nimi'].present?
      return store.categories.find_or_create_by!(name: data['Alatuoteryhmän nimi'], parent: parent, product_scope: :alphabetical)
    else
      return parent
    end
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
          value: excel_to_property_value(p, v)
        )
      }
    product.product_properties = properties
  end

  # Assigns product documentation from given file.
  def assign_documentation(product, pathname, filename)
    collection = product.documents
    collection.destroy_all
    path = "#{pathname}/#{filename}"
    if !filename.blank? && File.exist?(path)
      collection.create(priority: 0, attachment: File.new(path))
      puts "[doc0] %s" % [filename]
    end
  end

  # Assign technical image with given priority by first creating the picture
  # to contain it if necessary, then finding the correct image by file name.
  def assign_image(store, product, priority, filename)
    collection = product.pictures.technical
    image = store.images.find_by(attachment_file_name: filename)
    if image.present?
      picture = collection.find_or_initialize_by(priority: priority)
      picture.image = image
      picture.save!
      puts "[pic%1d] %s" % [priority, filename]
    else
      collection.destroy_all
    end
  end

  private
    def excel_to_property_value(p, v)
      return v.to_s if p.string?
      i = v.to_i
      d = v.to_f.round(2)
      return i.to_s if i == d
      d.to_s.sub('.', ',')
    end
end
