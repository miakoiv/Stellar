# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.precompile += %w(
  spry_themes/cards.css spry_themes/cards.js
  spry_themes/compass.css spry_themes/compass.js
  spry_themes/default.css spry_themes/default.js
  spry_themes/emek.css spry_themes/emek.js
  spry_themes/hiustalo.css spry_themes/hiustalo.js
  spry_themes/lepola.css spry_themes/lepola.js
  spry_themes/nineties.css spry_themes/nineties.js
  spry_themes/saarimedia.css spry_themes/saarimedia.js
  email/mailgun.css
)
