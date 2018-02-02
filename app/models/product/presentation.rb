class Product < ActiveRecord::Base

  INLINE_SEARCH_RESULTS = 20
  paginates_per 30

  PURPOSE_ICONS = {
    'vanilla' => nil,
    'bundle' => 'archive',
    'composite' => 'object-group',
    'virtual' => 'magic',
    'internal' => 'link',
    'component' => 'puzzle-piece'
  }.freeze

  before_save :generate_description, if: -> (product) { product.description.blank? }

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
    cover_image.present? && cover_image(:presentational).url(:icon, timestamp: false)
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
