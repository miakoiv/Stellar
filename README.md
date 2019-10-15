# Stellar Storefront

Stellar Storefront is a Ruby on Rails app to host multiple online stores with user-managed content, customizable themes, and onboarding to invite users to start their own stores.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

The default database configuration specifies [MySQL](https://www.mysql.com) (version 5.6 and up). For historical reasons, the database is named `spry` in development and testing. Production database URL is provided via an environment variable, see Deployment below.

Low-level caching requires [Memcached](https://memcached.org/) version 1.4 or higher. Changes to the default configuration need to be included in `config/initializers/mem_cache_store.rb`.

Image processing for [Paperclip](https://github.com/thoughtbot/paperclip) uploads requires [ImageMagick](https://imagemagick.org) to be installed. See `config/initializers/paperclip.rb` for configuration.

### Installing

To install Stellar Storefront on your server:

1. Clone the repo

  ```
  git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY
  ```

2. Set up your environment as described in the Deployment section below

  You need to define at least `SECRET_KEY_BASE` and `STELLAR_DATABASE_URL`, and set `RAILS_ENV` to `production`.

3. Set up the database and seed data

  ```
  rails db:setup
  ```

## Testing

Alas, this project does not include automated tests, yet. There are plans to write tests using Minitest and Capybara. Pull requests for tests are very much appreciated.

## Missing/unfinished Features

There is preliminary support for setting up paid plans for Stellar customers to subscribe to in order to have different features enabled in their online store. The plans are defined in `config/stripe` and Stripe handles the subscription and payment flow. However, the subscriptions do not affect the availability of any features yet.

## Deployment

Some environment variables need to be set in production:

`SECRET_KEY_BASE` is used as the encryption secret as per Rails 4.2. Run `rails secret` to generate one.

`STELLAR_DATABASE_URL` is a URL to the production database. For example `mysql2://user:password@localhost/stellar`.

`STELLAR_DOMAIN` is the domain name where Stellar Storefront is hosted. This is used as the e-mail sender domain. New stores created via onboarding are assigned a subdomain from this domain. For example `yourdomain.com`.

`STELLAR_HOST` is the hostname for the account management and onboarding endpoint. For example `account.yourdomain.com`.

`SENDGRID_API_KEY` is needed if mail is delivered using SendGrid. See `config/environments/production.rb` for mail configuration.

`STRIPE_PUBLIC_KEY` and `STRIPE_SECRET_KEY` are the key pair used for the Stripe API.

## Integrations

Stellar Storefront is able to talk to various 3rd party services to do payment processing, shipments, live chat, and external content. Most of the integrations are implemented using gateway modules.

`PaymentGateway` module includes classes to handle payments through an external service. Stellar currently includes one gateway, `Paybyway` that interfaces with the [Bambora Payform API](https://www.bambora.com/fi/fi/online/).

`ShippingGateway` module contains classes to interface with 3rd party services for registering shipments. Some shipping gateways work locally and expect the vendor to handle shipments themselves. There are gateways for [Posti Smartship](https://www.posti.fi/en/for-businesses/improve-logistics/digital-services-and-interfaces/smartship) through the [Unifaun API](), and Pakettikauppa through the [Pakettikauppa API](https://www.pakettikauppa.fi).

`ContentGateway` module provides access to external content. There are implementations for RSS feeds in either article or headline mode, as well as real estate listings provided by [Oikotie Asunnot](https://asunnot.oikotie.fi).

Other integrations include [Tawk.to](https://www.tawk.to) and [Google Maps](https://developers.google.com/maps/documentation/javascript/tutorial).

## Built With

* [Ruby on Rails](https://rubyonrails.org/) - version 5.2.3 (project started on 4.2)
* [Bootstrap](https://getbootstrap.com/docs/3.4/) - version 3.4
* [CKEditor 5](https://ckeditor.com/ckeditor-5/)
* [FontAwesome](https://fontawesome.com/v4.7.0/) - version 4.7.0
* [Droid Serif Font](https://www.fontsquirrel.com/fonts/droid-serif) - see [LICENSE](https://www.fontsquirrel.com/license/droid-serif)
* [Fira Sans Font](https://www.fontsquirrel.com/fonts/fira-sans) - see [LICENSE](https://www.fontsquirrel.com/license/fira-sans)
* [Montserrat Font](https://www.fontsquirrel.com/fonts/montserrat) - see [LICENSE](https://www.fontsquirrel.com/license/montserrat)

## Authors

* [LeasIT](https://leasit.fi)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
