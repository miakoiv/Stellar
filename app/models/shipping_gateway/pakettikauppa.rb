#
# Implementation of several shipping methods available through
# the Pakettikauppa API, using DB Schenker, Matkahuolto, and Posti
# as service providers. Each shipping method is defined as a subclass
# of ShippingGateway::Pakettikauppa::Base.
# For API docs, see <https://www.pakettikauppa.fi/tekniset-ohjeet/>
#
module ShippingGateway

  class PakettikauppaConnector
    include HTTParty
    base_uri Rails.configuration.x.pakettikauppa.api_uri
    logger Rails.logger

    def self.list_shipping_methods(query)
      post '/shipping-methods/list', query: query
    end

    def self.search_pickup_points(query)
      post '/pickup-points/search', query: query
    end

    def self.create_shipment(body)
      headers = {'Content-Type' => 'application/xml'}
      post '/prinetti/create-shipment', format: :xml,
        headers: headers, body: body
    end

    def self.get_shipping_label(body)
      headers = {'Content-Type' => 'application/xml'}
      post '/prinetti/get-shipping-label', format: :xml,
        headers: headers, body: body
    end
  end

  module Pakettikauppa

    class Base
      include ActiveModel::Model

      attr_accessor :order, :shipment, :user

      def self.fixed_cost?
        true
      end

      def self.requires_dimensions?
        true
      end

      def self.generates_labels?
        true
      end

      def initialize(attributes = {})
        super
        raise ArgumentError if order.nil?
        @store = order.store
        @api_key = '00000000-0000-0000-0000-000000000000'
        @secret = '1234567890ABCDEF'
        @locale = I18n.locale
      end

      def calculated_cost(base_price, metadata)
        base_price
      end

      def list_shipping_methods
        request = hmac_request(language: @locale)
        response = PakettikauppaConnector.list_shipping_methods(request)
          .parsed_response
      end

      def search_pickup_points(postalcode, provider)
        request = hmac_request(
          postcode: postalcode,
          service_provider: provider
        )
        PakettikauppaConnector.search_pickup_points(request).parsed_response
      end

      def send_shipment
        raise ArgumentError if shipment.nil? || user.nil?
        response = PakettikauppaConnector.create_shipment(shipment_xml)
          .parsed_response['Response']
        status = response['response.status'] == '0'

        return [
          status,
          status && response['response.reference']['__content__'],
          status && response['response.trackingcode']['__content__']
        ]
      end

      def fetch_label
        raise ArgumentError if shipment.nil?
        response = PakettikauppaConnector.get_shipping_label(label_xml)
          .parsed_response['Response']
        status = response['response.status'] == '0'

        return [
          status,
          status && Base64.decode64(response['response.file']['__content__'])
        ]
      end

      private

        def shipment_xml
          id = order.number
          shipping_method = shipment.shipping_method

          builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
            xml.eChannel do
              xml.ROUTING do
                xml.send 'Routing.Account', @api_key
                xml.send 'Routing.Key', md5(@api_key, id, @secret)
                xml.send 'Routing.Id', id
                xml.send 'Routing.Time', unix_time
              end
              xml.Shipment do
                xml.send 'Shipment.Sender' do
                  xml.send 'Sender.Name1', @store.name
                  xml.send 'Sender.Addr1', user.shipping_address
                  xml.send 'Sender.Postcode', user.shipping_postalcode
                  xml.send 'Sender.City', user.shipping_city
                  xml.send 'Sender.Country', user.shipping_country_code
                  xml.send 'Sender.Vatcode', @store.vat_number
                end
                xml.send 'Shipment.Recipient' do
                  xml.send 'Recipient.Name1', order.customer_name
                  xml.send 'Recipient.Addr1', order.shipping_address
                  xml.send 'Recipient.Postcode', order.shipping_postalcode
                  xml.send 'Recipient.City', order.shipping_city
                  xml.send 'Recipient.Country', order.shipping_country_code
                  xml.send 'Recipient.Phone', order.customer_phone
                  xml.send 'Recipient.Email', order.customer_email
                end
                xml.send 'Shipment.Consignment' do
                  xml.send 'Consignment.Reference', order.number
                  xml.send 'Consignment.Product', shipping_method.code
                  xml.send 'Consignment.Parcel' do
                    xml.send 'Parcel.Packagetype', shipment.package_type
                    xml.send 'Parcel.Weight', shipment.weight
                    xml.send 'Parcel.Volume', shipment.volume
                    xml.send 'Parcel.Contents', 'M' # Merchandise
                  end
                  if shipment.pickup_point_id.present?
                    xml.send 'Consignment.AdditionalService' do
                      xml.send 'AdditionalService.Servicecode', 2106
                      xml.send 'AdditionalService.Specifier', shipment.pickup_point_id, name: 'pickup_point_id'
                    end
                  end
                end
              end
            end
          end
          builder.to_xml
        end

        def label_xml
          id = order.number

          builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
            xml.eChannel do
              xml.ROUTING do
                xml.send 'Routing.Account', @api_key
                xml.send 'Routing.Key', md5(@api_key, id, @secret)
                xml.send 'Routing.Id', id
                xml.send 'Routing.Name', order.customer_name
                xml.send 'Routing.Time', unix_time
              end
              xml.PrintLabel do
                xml.Reference shipment.number
                xml.TrackingCode shipment.tracking_code
              end
            end
          end
          builder.to_xml
        end

        def hmac_request(params = {})
          request = params.merge(
            api_key: @api_key,
            timestamp: unix_time
          )
          plaintext = request.sort.map { |_, v| v }.join('&')
          request.merge(hash: sha256(@secret, plaintext))
        end

        def sha256(secret, data)
          OpenSSL::HMAC.hexdigest('sha256', secret, data)
        end

        def md5(*parts)
          Digest::MD5.hexdigest(parts.join)
        end

        def unix_time
          Time.now.to_i
        end
    end

    class DbSchenker < Base
      def self.requires_maps?
        true
      end

      def search_pickup_points(postalcode)
        super(postalcode, 'Db Schenker')
      end

      def to_partial_path
        'shipping_gateway/pakettikauppa/db_schenker'
      end
    end

    class Matkahuolto < Base
      def self.requires_maps?
        false
      end

      def to_partial_path
        'shipping_gateway/pakettikauppa/matkahuolto'
      end
    end

    class Posti < Base
    end
  end
end
