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
  # VARASTO,NRO,HYLLY,VARASTOLKM,VARATTULKM,TULOSSA,TILAUSPIST,INVENTLKM,INVENTPVM,VARHINTA
  inventory: {
    file: 'www-nimike_varasto-utf8.csv',
    multiple: true,
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
            find_or_create_product(store, code, data).update_columns(
              customer_code: row[:customer_code],
              sales_price: row[:sales_price] || data[:sales_price],
              sales_price_modified_at: data[:sales_price_modified_at]
            )
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
            find_or_create_product(store, code, data).update_columns(
              sales_price: data[:sales_price],
              sales_price_modified_at: data[:sales_price_modified_at]
            )
          end
        end

        # Update inventory items in global inventory.
        update_inventory(
          Inventory.global.by_purpose(:manufacturing),
          code, data[:product][:quantity_pending]
        )
        update_inventory(
          Inventory.global.by_purpose(:shipping),
          code, data[:product][:quantity_on_hand]
        )

        # Update inventory items in local inventories.
        next if data[:inventory].nil?
        data[:inventory].each do |row|
          store = Store.find_by(inventory_code: row[:inventory_code])
          update_inventory(
            store.inventory_for(:manufacturing),
            code, row[:quantity_pending], row[:shelf], row[:value]
          )
          update_inventory(
            store.inventory_for(:shipping),
            code, row[:quantity_on_hand], row[:shelf], row[:value]
          )
        end

        # Assign product relationships.
        next if data[:structure].nil?
        data[:structure].each do |row|
          Relationship.find_or_create_by(
            parent_code: code, product_code: row[:component_code]
          ).update_columns(
            quantity: row[:quantity].to_i
          )
        end
      end
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
    product.save(validate: false)
    product.update_columns(
      title:            data[:product][:title]   .try(:mb_chars).try(:titleize),
      subtitle:         data[:product][:subtitle].try(:mb_chars).try(:titleize),
      memo:             data[:product][:memo],
      cost:             data[:cost],
      cost_modified_at: data[:cost_modified_at]
    )
    product
  end

  # Updates an inventory item by product code in specified inventory,
  # which may not exist.
  def update_inventory(inventory, code, quantity, shelf = nil, value = nil)
    return nil if inventory.nil?
    inventory.inventory_items.find_or_create_by(code: code).update_columns(
      amount: quantity,
      shelf: shelf,
      value: value
    )
  end
end
