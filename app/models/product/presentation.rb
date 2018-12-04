class Product < ActiveRecord::Base

  INLINE_SEARCH_RESULTS = 20
  paginates_per 30

  PURPOSE_ICONS = {
    'vanilla' => nil,
    'bundle' => 'archive',
    'composite' => 'object-group',
    'package' => 'object-group',
    'virtual' => 'magic',
    'internal' => 'link',
    'component' => 'puzzle-piece'
  }.freeze

  #---
  before_save :generate_description, if: -> (product) { product.description.blank? }

  #---
  def self.to_csv
    attributes = %w{code customer_code title subtitle picture_count description}
    CSV.generate(
      headers: true,
      col_sep: ';',
      force_quotes: true
    ) do |csv|
      csv << attributes
      all.each do |product|
        csv << attributes.map { |k| product.send(k) }
      end
    end
  end

  #---
  # Icon name based on purpose.
  def icon
    PURPOSE_ICONS[purpose]
  end

  def codes
    customer_code.present? ? "#{customer_code} ⧸ #{code}" : code
  end

  def to_s
    "#{title} #{subtitle}"
  end

  def as_json(options = {})
    super({
      only: [:id, :code, :customer_code, :title, :subtitle],
      methods: [:icon_image_url]
    }.merge(options))
  end

  def icon_image_url
    cover_picture.present? && cover_picture(:presentational).image.url(:icon, timestamp: false)
  end

  # Retail price string representation for JSON.
  def formatted_price_string
    retail_price.present? ? retail_price.format : ''
  end

  private
    # Generates the description as a plain text representation of overview.
    def generate_description
      html = Nokogiri::HTML(overview)
      lines = html.search('//text()').map(&:text)
      self[:description] = lines.join("\n")
    end
end
