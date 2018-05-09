Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = {
    host: ENV['DEFAULT_URL_HOST'],
    port: ENV['DEFAULT_URL_PORT'] || 80
  }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Prefix development assets path to ignore locally compiled assets
  # in development, and serving them via Sprockets.
  # http://guides.rubyonrails.org/asset_pipeline.html#local-precompilation
  config.assets.prefix = '/dev-assets'

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  # Do not raise exceptions for missing assets.
  config.assets.check_precompiled_asset = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Suppresses logger output for asset requests.
  config.assets.quiet = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = false

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Whitelist our virtual IP address block to the web console.
  config.web_console.whitelisted_ips = '10.2.0.0/16'

  # API configuration.
  config.x.pakettikauppa.api_uri = 'https://apitest.pakettikauppa.fi/'
  config.x.paybyway.api_uri = 'https://payform.bambora.com/pbwapi/'
end
