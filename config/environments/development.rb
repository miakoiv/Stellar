Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = {
    protocol: 'http',
    host: ENV['STELLAR_HOST']
  }
  config.action_mailer.perform_caching = false

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

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = false

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Whitelist our local IP address block to the web console.
  config.web_console.whitelisted_ips = '10.2.0.0/16'

  # API configuration.
  config.x.oikotie_asunnot.api_uri = 'https://asunnot.oikotie.fi/api/4.0/'
  config.x.pakettikauppa.api_uri = 'https://apitest.pakettikauppa.fi/'
  config.x.paybyway.api_uri = 'https://payform.bambora.com/pbwapi/'
  config.stripe.publishable_key = 'pk_test_HpO1Z1azrRN6l4M35cQSxLCE'
  config.stripe.secret_key = 'sk_test_Ci2RTHLxv2G5K0CVbaDK43Px'
  config.stripe.signing_secret = 'whsec_mqLWeLD1eq8lUzBLy3B6CWPh10ye7QY3'
end
