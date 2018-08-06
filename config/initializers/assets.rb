# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# This path is needed by StyleGenerator to compile assets on demand
Rails.application.config.assets.paths << File.join(
  Rails.root, 'tmp', 'cache', 'assets'
)

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.precompile += %w(
  jasny-bootstrap/rowlink.js
  payment_gateway/paybyway.js
  spry_themes/birch.css       spry_themes/birch.js
  spry_themes/boutique.css    spry_themes/boutique.js
  spry_themes/cards.css       spry_themes/cards.js
  spry_themes/cottage.css     spry_themes/cottage.js
  spry_themes/hiustalo.css    spry_themes/hiustalo.js
  spry_themes/material.css    spry_themes/material.js
  spry_themes/mechanet.css    spry_themes/mechanet.js
  spry_themes/premium.css     spry_themes/premium.js
  email/mailgun.css
  hamburgers/hamburgers.css
)
