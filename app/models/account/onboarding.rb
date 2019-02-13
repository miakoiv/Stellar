#
# Account::Onboarding models the workflow for creating new stores
# and others objects required for its operation from user input
# spanning multiple steps using a wizard-like UX.
#
# Each step is a subclass of Account::Onboarding::Base, which
# defines the attributes collected from the user, and a method to
# finalize the onboarding process by creating the actual records.
# The subclasses inherit from Base and all previous steps, adding
# necessary validators and defining when registration is required.
#
module Account
  module Onboarding

    STEPS = %w{frontend backend admin}.freeze

    class Base
      include ActiveModel::Model
      include ActiveRecord::AttributeAssignment

      def self.locale_options
        @@locale_options ||= [
          ['suomi', 'fi'],
          ['English', 'en']
        ]
      end

      def self.country_options
        ::Store.country_options
      end

      attr_accessor :name, :theme,
                    :country_code, :locale, :subdomain, :domain,
                    :admin_name, :vat_number

      def initialize(attributes = {})
        super
        @country_code ||= 'FI'
        @locale ||= 'fi'
        @domain ||= ENV['STELLAR_DOMAIN']
      end

      def attributes
        {
          name: @name,
          theme: @theme,
          country_code: @country_code,
          locale: @locale,
          subdomain: @subdomain,
          domain: @domain,
          admin_name: @admin_name,
          vat_number: @vat_number
        }
      end

      def requires_registration?
        false
      end

      def fqdn
        [subdomain, domain].join '.'
      end

      def finalize!(user)
        Store.transaction do
          store = Store.create!(
            name: name,
            theme: theme,
            country_code: country_code,
            locale: locale,
            vat_number: vat_number,
            admit_guests: true,
            fancy_cart: true,
            favorites: true,
            order_sequence: '100000',
            card_image_type: 'presentational',
            list_image_type: 'presentational'
          )
          store.hostnames.create!(fqdn: fqdn)
          store.tax_categories.create!(
            TaxCategory.defaults_for_locale(locale)
          )
          group = store.groups.create!(name: name)
          user.update!(name: admin_name)
          user.groups << group
          Role.onboarding.each do |role|
            user.grant(role, store)
          end
          store
        end
      end
    end

    class Frontend < Base
      validates :name, presence: true
      validates :theme, presence: true
    end

    class Backend < Frontend
      validates :country_code, presence: true
      validates :locale, presence: true
      validates :subdomain, presence: true, format: {with: /\A[a-z0-9-]+\z/}
      validate :subdomain_availability

      def initialize(attributes = {})
        super
        @subdomain ||= name.parameterize
      end

      private
        def subdomain_availability
          hostname = Hostname.new(fqdn: fqdn)
          errors.add(:subdomain, :not_available) if hostname.invalid?
        end
    end

    class Admin < Backend
      validates :admin_name, presence: true

      def requires_registration?
        true
      end
    end
  end
end
