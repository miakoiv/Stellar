#encoding: utf-8

require 'csv'

IMPORT_PATH = Pathname.new '/etc/dropbox/Dropbox/extranet'

PRODUCT_FILES = {

  # PIIRNRO,NRO,NIMI,NIMI2,
  # MYYNTHINTA,STDHINTA,PVMMYYN,PVMSTD,
  # VARASTOLKM,VARATTULKM,TULOSSA,
  # TARVE_ETU,MUISTIO4
  product: {
    file: 'www-nimike-utf8.csv',
    multiple: false,
    headers: [
      :stores, :code, :title, :subtitle,
      :trade_price, :cost_price,
      :trade_price_modified_at, :cost_price_modified_at,
      :quantity_on_hand, :quantity_reserved, :quantity_pending,
      :additional_stores, :memo
    ],
  },
  # NRO,ASIAKNRO,ASIAKNIMI,ASIAKTNRO,MYYNTHINTA,VALUUTTA,MYYNTIERA,PAIVPVM
  customers: {
    file: 'www-nimike_asiakas-utf8.csv',
    multiple: true,
    headers: [
      :code, :erp_number, nil, :customer_code,
      :trade_price, nil, nil, :trade_price_modified_at
    ],
  },
  # VARASTO,NRO,HYLLY,
  # VARASTOLKM,VARATTULKM,TULOSSA,
  # TILAUSPIST,INVENTLKM,INVENTPVM,VARHINTA
  inventories: {
    file: 'www-nimike_varasto-utf8.csv',
    multiple: true,
    headers: [
      :inventory_code, :code, nil,
      :quantity_on_hand, :quantity_reserved, :quantity_pending,
      nil, nil, nil, :value
    ],
  },
  # PAANUMERO,ALINUMERO,PAATMP,ALITMP,LKM,TARVE1,TARVE2,BTARVE1,BTARVE2,SELITE
  #structure: {
  #  file: 'www-nimike_rakenne-utf8.csv',
  #  multiple: true,
  #  headers: [:code, :component_code, nil, nil, :quantity]
  #},
}

ORDER_FILES = {

  # TILNRO,LSTNO,ASTILNRO,VAIHE1
  order: {
    file: 'www-tilaus-utf8.csv',
    multiple: false,
    headers: [:code, :erp_number, :number, :status],
  },
}

namespace :matfox do
  desc "Import data from Matfox"
  task import: :environment do |task, args|
    @data_by_product_code = import_data(PRODUCT_FILES)
    @data_by_order_code = import_data(ORDER_FILES)

    Product.transaction do

      @data_by_product_code.each do |code, data|
        next if data[:product].nil?

        # Each product may exist in one or several stores separately,
        # based on entries in inventories data.
        if data[:inventories].present?
          data[:inventories].each do |row|
            inventories = Inventory.where(inventory_code: row[:inventory_code])
            inventories.each do |inventory|
              product = find_or_create_product(inventory.store, code, data)
              next if product.nil?
              update_inventory(inventory, product, row)
            end
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
            next if product.nil?
            update_trade_price(product, data[:product])
          end
        end

        # Customer data is used to update product data in stores
        # with a matching ERP number.
        if data[:customers].present?
          data[:customers].each do |row|
            Store.where(erp_number: row[:erp_number]).each do |store|
              product = store.products.find_by(code: code)
              next if product.nil?
              product.update(customer_code: row[:customer_code]) if product.customer_code.nil?
              price_data = row[:trade_price].present? ? row : data[:product]
              update_trade_price(product, price_data)
            end
          end
        end
      end
    end

    Order.transaction do

      @data_by_order_code.each do |code, data|
        next if data[:order].nil?

        # Orders are found by the number field, which might not match
        # any known order, or may refer to an already concluded one.
        next unless data[:number] =~ /\A\d+\Z/
        store = Store.find_by(erp_number: data[:erp_number])
        next if store.nil?
        order = store.orders.find_by(number: data[:number])
        next if order.nil? || order.concluded?

        # Each order has a status of 2..4, where status 2 triggers
        # approval, and 4 triggers conclusion.
        approve_order(order)  if data[:order][:status] == '2'
        conclude_order(order) if data[:order][:status] == '4'
      end
    end
  end

  # Updates the inventory item entry for `product` in `inventory`.
  # Given `data` must contain the inventory data fields.
  def update_inventory(inventory, product, data)
    create_inventory_item(
      inventory, product,
      data[:quantity_on_hand],
      data[:quantity_reserved],
      data[:quantity_pending],
      data[:value]
    )
  end

  # Import specified files into a hash of hashes, where the top level key 'i'
  # is the field 'code', the second level key 'j' is the files hash key.
  # Import file options may specify either single or multiple record mode.
  def import_data(files)
    data = {}
    files.each do |j, options|
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
    product.cost_price = data[:product][:cost_price]
    product.cost_price_modified_at = data[:product][:cost_price_modified_at]
    product.tax_category ||= store.tax_categories.first
    puts "#{store.name} #{product.code} #{product.title} #{product.subtitle}"
    if product.save
      product
    else
      puts product.errors.full_messages.map { |m| "! #{m}"}
      nil
    end
  end

  # Updates product trade price data from given `data`.
  def update_trade_price(product, data)
    trade_price = data[:trade_price]
    if trade_price.present? && trade_price.to_f > 0
      product.update(
        trade_price: trade_price,
        trade_price_modified_at: data[:trade_price_modified_at]
      )
      puts "€ #{product.code} #{product.title} #{product.subtitle} #{trade_price}"
    end
  end

  # Creates an inventory item for `product` in `inventory`.
  def create_inventory_item(inventory, product, on_hand, reserved, pending, value)
    puts "→ #{inventory.name} #{on_hand} #{reserved} #{pending}"

    # Purges any existing inventory items for this product.
    inventory.inventory_items.where(product: product).destroy_all

    item = inventory.inventory_items.build(
      product: product,
      code: Time.current.to_i
    )
    item.inventory_entries.build(
      recorded_at: Date.today,
      on_hand: on_hand.to_i || 0,
      reserved: reserved.to_i || 0,
      pending: pending.to_i || 0,
      value: value || 0
    )
    item.save!
  end

  # Sets the approval timestamp of given order, if currently unset.
  def approve_order(order)
    return false if order.approved?
    order.update(approved_at: Time.current)
    puts "#{order.number} approved"
  end

  # Sets the conclusion timestamp of given order, if currently unset.
  # Ensures the order is approved first.
  def conclude_order(order)
    approve_order(order)
    return false if order.concluded?
    order.update(concluded_at: Time.current)
    puts "#{order.number} concluded"
  end

=begin
  # Updates the component entries of `product` according to entries
  # in `structure`, in the scope of `store`.
  def update_structure(store, product, structure)
    if structure.nil?
      product.component_entries.clear
    else
      component_entries = structure.map { |row|
        [
          store.products.find_by(code: row[:component_code]),
          row[:quantity].to_i
        ]
      }.reject { |row| row[0].nil? }

      # First mass assign the components to delete unwanted entries.
      product.component_products = component_entries.map { |r| r[0] }

      # Now update quantities on the component entries.
      component_entries.each do |entry|
        product.component_entries.find_by(
          component: entry[0]
        ).update(
          quantity: entry[1]
        )
      end
    end
  end
=end
end
