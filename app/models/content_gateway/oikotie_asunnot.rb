#encoding: utf-8
#
# ContentGateway::OikotieAsunnot implements a content gateway
# interface to the Oikotie Asunnot API. Documentation is at
# <http://api.asunnot.oikotie.fi/>.
#
# To use the gateway, initialize a ContentGateway::OikotieAsunnot
# object with a store argument that contains the oikotie_asunnot_api_key
# and oikotie_asunnot_broker_id attributes needed for accessing the API.
#
# Calling the feed method will access the API to load a collection of
# cards as ContentItem objects. The feed method accepts options to
# control the desired card type and number of items.
#
module ContentGateway

  class OikotieAsunnot
    include HTTParty
    base_uri Rails.configuration.x.oikotie_asunnot.api_uri
    headers 'Content-Type' => 'application/json'
    format :json
    logger Rails.logger

    # Known card types according to API documentation.
    CARD_TYPES = {
      apartment_sell: 100,
      apartment_rent: 101,
      vacationhome_sell: 102,
      vacationhome_rent: 103,
      lot_sell: 104,
      business_sell: 105,
      business_rent: 106,
      farm_sell: 107,
      parking_sell: 108,
      parking_rent: 109,
      apartment_tenant: 110
    }.freeze

    attr_reader :api_key, :broker_id

    def initialize(store)
      @store = store
      @api_key = @store.oikotie_asunnot_api_key
      @broker_id = @store.oikotie_asunnot_broker_id
    end

    # Loads the feed and returns a tuple of [items, count]
    def feed(params = {})
      page = params['page'].present? ? params['page'].to_i : 1
      items = params['items'].to_i
      options = params.merge(
        cardType: card_type(params['contentType']),
        brokerCompanyId: broker_id,
        sortBy: :published_desc,
        offset: items * (page - 1),
        limit: items
      )
      response = self.class.get('/cards',
        headers: {key: api_key},
        query: options,
        timeout: 10
      ).parsed_response
      if response['cards'].present?
        items = response['cards'].map { |card| build_content_item(card) }
        [items, response['found']]
      else
        [[], 0]
      end
    end

    private
      def card_type(content_type)
        CARD_TYPES[content_type.to_sym] || CARD_TYPES[:apartment_sell]
      end

      # Returns a new content item from given card data,
      # applying necessary transformations.
      def build_content_item(card)
        ContentItem.new(
          title: card['buildingData']['address'],
          subtitle: card['buildingData']['district'] + ', ' + card['buildingData']['city'],
          image: card['images']['wide'],
          description: card['description'],
          link: card['url'],
          price: card['price'] != 0 ? card['price'] : nil,
          type: card['roomConfiguration'],
          size: card['size'] != 0 ? '%d m²' % card['size'] : nil
        )
      end
  end
end
