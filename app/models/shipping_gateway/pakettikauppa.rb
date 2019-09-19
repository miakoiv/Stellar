#
# Implementation of several shipping methods available through
# the Pakettikauppa API, using DB Schenker, Matkahuolto, and Posti
# as service providers. Each shipping method is defined as a subclass
# of ShippingGateway::Pakettikauppa::Base.
# For API docs, see <https://www.pakettikauppa.fi/tekniset-ohjeet/>
#
module ShippingGateway
  module Pakettikauppa
    class Base
      include ActiveModel::Model

      TEST_KEY = '00000000-0000-0000-0000-000000000000'
      TEST_SECRET = '1234567890ABCDEF'

      attr_accessor :order, :shipment, :user, :data

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
        raise ShippingGatewayError, 'Order not specified' if order.nil?
        @store = order.store
        @group = user&.group(@store)
        @api_key = @store.pakettikauppa_api_key.presence || TEST_KEY
        @secret = @store.pakettikauppa_secret.presence || TEST_SECRET
        @locale = I18n.locale
        @api = ShippingGateway::Connector::Pakettikauppa.new(@api_key, @secret)
      end

      def prepare_interface_data(params = {})
        {}
      end

      def calculated_cost(base_price, metadata)
        base_price
      end

      def list_shipping_methods
        request = {language: @locale}
        @api.list_shipping_methods(request).parsed_response
      end

      def search_pickup_points(postalcode, provider)
        request = {
          postcode: postalcode,
          service_provider: provider
        }
        @api.search_pickup_points(request).parsed_response
      end

      def send_shipment
        raise ShippingGatewayError, 'Shipment and user must be present' if shipment.nil? || user.nil?
        raise ShippingGatewayError, 'Shipping address must be present' unless @group.shipping_address.present?
        response = @api.create_shipment(shipment_xml).parsed_response['Response']
        status = response['response.status'] == '0'

        raise ShippingGatewayError, response['response.message'] unless status
        return [
          status,
          status && response['response.reference']['__content__'],
          status && response['response.trackingcode']['__content__']
        ]
      end

      def fetch_label
        raise ShippingGatewayError, 'Shipment must be present' if shipment.nil?
        response = @api.get_shipping_label(label_xml).parsed_response['Response']
        status = response['response.status'] == '0'

        raise ShippingGatewayError, response['response.message'] unless status
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
                xml.send 'Routing.Time', Time.now.to_i
              end
              xml.Shipment do
                xml.send 'Shipment.Sender' do
                  xml.send 'Sender.Name1', @store.name
                  if @group.present?
                    xml.send 'Sender.Addr1', @group.shipping_address.address1
                    xml.send 'Sender.Postcode', @group.shipping_address.postalcode
                    xml.send 'Sender.City', @group.shipping_address.city
                    xml.send 'Sender.Country', @group.shipping_address.country_code
                  end
                  xml.send 'Sender.Vatcode', @store.vat_number
                end
                xml.send 'Shipment.Recipient' do
                  xml.send 'Recipient.Name1', order.shipping_address.name
                  xml.send 'Recipient.Addr1', order.shipping_address.address1
                  xml.send 'Recipient.Postcode', order.shipping_address.postalcode
                  xml.send 'Recipient.City', order.shipping_address.city
                  xml.send 'Recipient.Country', order.shipping_address.country_code
                  xml.send 'Recipient.Phone', order.shipping_address.phone
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
                xml.send 'Routing.Name', order.shipping_address.name
                xml.send 'Routing.Time', Time.now.to_i
              end
              xml.PrintLabel do
                xml.Reference shipment.number
                xml.TrackingCode shipment.tracking_code
              end
            end
          end
          builder.to_xml
        end

        def md5(*parts)
          Digest::MD5.hexdigest(parts.join)
        end
    end

    class DbSchenker < Base
      def prepare_interface_data(params = {})
        postalcode = params[:postalcode] || order.shipping_address.postalcode
        locations = search_pickup_points(postalcode)
        {
          postalcode: postalcode,
          locations: locations
        }
      end

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
      def prepare_interface_data(params = {})
        postalcode = params[:postalcode] || order.shipping_address.postalcode
        locations = search_pickup_points(postalcode)
        {
          postalcode: postalcode,
          locations: locations
        }
      end

      def self.requires_maps?
        true
      end

      def search_pickup_points(postalcode)
        super(postalcode, 'Posti')
      end

      def to_partial_path
        'shipping_gateway/pakettikauppa/posti'
      end
    end
  end
end
