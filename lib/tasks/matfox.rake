#encoding: utf-8

require 'csv'

IMPORT_PATH = Pathname.new '/etc/dropbox/Dropbox/extranet'

IMPORT_FILES = {

  # PIIRNRO,NRO,NIMI,NIMI2,
  # MYYNTHINTA,STDHINTA,PVMMYYN,PVMSTD,
  # VARASTOLKM,VARATTULKM,TULOSSA,
  # TARVE_ETU,MUISTIO4
  product: {
    file: 'www-nimike-utf8.csv',
    multiple: false,
    headers: [
      :stores, :code, :title, :subtitle,
      :sales_price, :cost, :sales_price_modified_at, :cost_modified_at,
      :quantity_on_hand, :quantity_reserved, :quantity_pending,
      :additional_stores, :memo
    ],
  },
  # NRO,ASIAKNRO,ASIAKNIMI,ASIAKTNRO,MYYNTHINTA,VALUUTTA,MYYNTIERA,PAIVPVM
  customers: {
    file: 'www-nimike_asiakas-utf8.csv',
    multiple: true,
    headers: [:code, :erp_number, nil, :customer_code, :sales_price],
  },
  # VARASTO,NRO,HYLLY,
  # VARASTOLKM,VARATTULKM,TULOSSA,
  # TILAUSPIST,INVENTLKM,INVENTPVM,VARHINTA
  inventory: {
    file: 'www-nimike_varasto-utf8.csv',
    multiple: false,
    headers: [
      :inventory_code, :code, :shelf,
      :quantity_on_hand, :quantity_reserved, :quantity_pending,
      nil, nil, nil, :value
    ],
  },
  # PAANUMERO,ALINUMERO,PAATMP,ALITMP,LKM,TARVE1,TARVE2,BTARVE1,BTARVE2,SELITE
  structure: {
    file: 'www-nimike_rakenne-utf8.csv',
    multiple: true,
    headers: [:code, :component_code, nil, nil, :quantity]
  },
}

namespace :matfox do
  desc "Import data from Matfox"
  task import: :environment do |task, args|
    @data_by_product_code = import_data

    Product.transaction do

      @data_by_product_code.each do |code, data|
        next if data[:product].nil?

        # Each product may exist in one or several stores separately.
        # If the product has customers assigned, the corresponding store
        # is found by the customer's ERP number.
        if data[:customers].present?
          data[:customers].each do |row|
            store = Store.find_by(erp_number: row[:erp_number])
            next if store.nil?
            product = find_or_create_product(store, code, data)
            product.update(
              customer_code: row[:customer_code],
              sales_price: row[:sales_price].present? ? row[:sales_price] : data[:product][:sales_price],
              sales_price_modified_at: data[:product][:sales_price_modified_at]
            )
            update_inventory(store, product, data[:product], data[:inventory])
            update_structure(store, product, data[:structure])
          end
        end

        # Additional stores may be specified by listing store slugs
        # in the `additional_stores` field. As future expansion,
        # product variants will identify their parent product by `#code`.
        if data[:product][:additional_stores].present?
          slugs, variant_of = data[:product][:additional_stores].split '#'
          slugs.mb_chars.scan(/[[:word:]]+/).map(&:downcase).each do |slug|
            store = Store.find_by(slug: slug)
            next if store.nil?
            product = find_or_create_product(store, code, data)
            product.update(
              sales_price: data[:product][:sales_price],
              sales_price_modified_at: data[:product][:sales_price_modified_at]
            )
            update_inventory(store, product, data[:product], data[:inventory])
            update_structure(store, product, data[:structure])
          end
        end
      end
    end
  end

  # Updates the inventory item entry for `product` at `store`.
  def update_inventory(store, product, product_data, inventory_data)

    # Create stubs to ensure each product at least exists in each inventory.
    store.inventories.each do |inventory|
      find_or_create_inventory_item(store, inventory, product)
    end

    # If the inventory code in `inventory_data` matches the store,
    # it is preferred over `product_data`.
    if inventory_data.present? &&
        inventory_data[:inventory_code] == store.inventory_code

      update_inventory_item(
        store, store.inventory_for(:manufacturing), product,
        inventory_data[:quantity_pending],
        inventory_data[:shelf],
        inventory_data[:value]
      )
      update_inventory_item(
        store, store.inventory_for(:shipping), product,
        inventory_data[:quantity_on_hand],
        inventory_data[:shelf],
        inventory_data[:value]
      )
    else
      update_inventory_item(
        store, store.inventory_for(:shipping), product,
        product[:quantity_on_hand], nil, nil
      )
    end
  end

  # Import all import files into a hash of hashes, where the top level key 'i'
  # is the field 'code', the second level key 'j' is the IMPORT_FILES key.
  # Import file options may specify either single or multiple record mode.
  def import_data
    data = {}
    IMPORT_FILES.each do |j, options|
      CSV.foreach(IMPORT_PATH.join(options[:file]), headers: options[:headers]) do |row|
        i = row[:code]
        data[i] ||= {}
        if options[:multiple]
          data[i][j] ||= []
          data[i][j] << row
        else
          data[i][j] = row
        end
      end
    end
    data
  end

  # Finds or creates a product by `code` in the scope of `store`,
  # specified in the hash `data`.
  def find_or_create_product(store, code, data)
    product = Product.find_or_initialize_by(store: store, code: code)
    product.title ||= data[:product][:title].try(:mb_chars).try(:titleize)
    product.subtitle ||= data[:product][:subtitle].try(:mb_chars).try(:titleize)
    product.memo = data[:product][:memo]
    product.cost = data[:product][:cost]
    product.cost_modified_at = data[:product][:cost_modified_at]
    puts product.to_json
    product.save!
    product
  end

  # Finds or creates inventory item for `product` in `inventory` at `store`.
  def find_or_create_inventory_item(store, inventory, product)
    inventory.inventory_items.find_or_create_by(store: store, product: product)
  end

  def update_inventory_item(store, inventory, product, amount, shelf, value)
    find_or_create_inventory_item(
      store, inventory, product
    ).update(
      amount: amount || 0,
      shelf: shelf,
      value: value || 0
    )
  end

  # Updates the relationships of `product` according to entries
  # in `structure`, in the scope of `store`.
  def update_structure(store, product, structure)
    if structure.nil?
      product.relationships.clear
    else
      relationships = structure.map { |row|
        [
          store.products.find_by(code: row[:component_code]),
          row[:quantity].to_i
        ]
      }.reject { |row| row[0].nil? }

      # First mass assign the components to delete unwanted relationships.
      product.components = relationships.map { |r| r[0] }

      # Now update quantities on the relationships.
      relationships.each do |relationship|
        product.relationships.find_by(
          component: relationship[0]
        ).update(
          quantity: relationship[1]
        )
      end
    end
  end
end
